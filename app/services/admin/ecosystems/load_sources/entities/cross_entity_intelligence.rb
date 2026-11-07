# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class CrossEntityIntelligence
        STALE_AFTER = 90.days
        RECENT_ACTIVITY_WINDOW = 30.days

        # Supports all existing calling styles:
        #
        # CrossEntityIntelligence.new(Entity.all)
        # CrossEntityIntelligence.new(entities: Entity.all)
        # CrossEntityIntelligence.new({ entities: Entity.all })
        #
        # Also supports a hash containing additional options.

        def initialize(scope = nil, **options)
          candidate =
            options[:entities] ||
              options[:scope] ||
              scope

          if candidate.is_a?(Hash)
            candidate =
              candidate[:entities] ||
                candidate["entities"] ||
                candidate[:scope] ||
                candidate["scope"]
          end

          @scope =
            candidate || self.class.default_scope
        end

        def self.default_scope
          ::Ecosystems::LoadSources::Entity::Entity.all
        end

        # Allows existing views that call .call to continue working.
        def call
          dashboard
        end

        def dashboard
          scope = @scope

          # Normalize wrapped arguments before calling ActiveRecord methods.
          while scope.is_a?(Hash)
            scope =
              scope[:entities] ||
                scope["entities"] ||
                scope[:scope] ||
                scope["scope"]

            break if scope.nil?
          end

          scope ||= self.class.default_scope

          unless scope.respond_to?(:includes)
            raise ArgumentError,
                  "Expected an ActiveRecord relation for entities, got #{scope.class}"
          end

          entities =
            scope
              .includes(:entity_type, :entity_template)
              .to_a

          relationships =
            EntityRelationship
              .active
              .includes(:source_entity, :target_entity)
              .to_a

          {
            metrics: metrics(entities, relationships),
            hotspots: hotspots(relationships),
            isolated: isolated_entities(entities, relationships),
            review_opportunities: review_opportunities(entities),
            stale_entities: stale_entities(entities),
            recent_activity: recent_activity(entities)
          }
        end

        def for_entity(entity)
          relationships =
            EntityRelationship
              .active
              .where(
                "source_entity_id = :id OR target_entity_id = :id",
                id: entity.id
              )
              .includes(:source_entity, :target_entity)
              .order(confidence: :desc)
              .to_a

          neighbors =
            relationships
              .map do |relationship|
                relationship.other_entity_for(entity)
              end
              .compact

          {
            entity: entity,

            relationship_count: relationships.length,

            relationships: relationships,

            neighbors: neighbors,

            health: entity.health_summary,

            signals: entity_signals(
              entity,
              relationships.length
            )
          }
        end

        private

        def entity_scope
          scope =
            @scope

          # Normalize a Hash defensively in case the service is
          # initialized with a wrapped scope from an older caller.
          if scope.is_a?(Hash)
            scope =
              scope[:entities] ||
              scope["entities"] ||
              scope[:scope] ||
              scope["scope"]
          end

          scope ||= self.class.default_scope

          unless scope.respond_to?(:includes)
            raise ArgumentError,
              "CrossEntityIntelligence expects an ActiveRecord relation " \
              "or an options hash containing :entities. " \
              "Received: #{scope.class}"
          end

          scope
        end

        def metrics(entities, relationships)
          {
            entities: entities.length,

            relationships: relationships.length,

            confirmed_relationships:
              relationships.count(&:confirmed?),

            suggested_relationships:
              relationships.count(&:suggested?),

            high_confidence_relationships:
              relationships.count do |relationship|
                relationship.confidence.to_f >= 0.70
              end,

            isolated_entities:
              isolated_entities(
                entities,
                relationships
              ).length,

            review_queue:
              entities.count do |entity|
                entity.respond_to?(:workflow_state_review?) &&
                  entity.workflow_state_review?
              end
          }
        end

        def hotspots(relationships)
          counts = Hash.new(0)

          relationships.each do |relationship|
            counts[relationship.source_entity_id] += 1
            counts[relationship.target_entity_id] += 1
          end

          top_ids =
            counts
              .sort_by { |_id, count| -count }
              .first(12)

          entities_by_id =
            if top_ids.any?
              self.class.default_scope
                .where(id: top_ids.map(&:first))
                .includes(:entity_type, :entity_template)
                .index_by(&:id)
            else
              {}
            end

          top_ids.map do |id, count|
            {
              entity: entities_by_id[id],
              relationship_count: count
            }
          end
        end

        def isolated_entities(entities, relationships)
          connected_ids =
            relationships
              .flat_map do |relationship|
                [
                  relationship.source_entity_id,
                  relationship.target_entity_id
                ]
              end
              .compact
              .uniq

          entities
            .reject do |entity|
              connected_ids.include?(entity.id)
            end
            .first(25)
        end

        def review_opportunities(entities)
          entities
            .select do |entity|
              review_candidate?(entity)
            end
            .sort_by do |entity|
              [
                safe_health_score(entity),
                entity.updated_at || Time.at(0)
              ]
            end
            .first(25)
        end

        def review_candidate?(entity)
          return false unless entity.respond_to?(:workflow_state)

          entity.workflow_state.to_s == "review" ||
            safe_health_score(entity) < 70
        end

        def safe_health_score(entity)
          return 100 unless entity.respond_to?(:health_score)

          entity.health_score.to_f
        end

        def stale_entities(entities)
          cutoff =
            Time.current - STALE_AFTER

          entities
            .select do |entity|
              entity.updated_at.present? &&
                entity.updated_at < cutoff
            end
            .sort_by(&:updated_at)
            .first(25)
        end

        def recent_activity(entities)
          cutoff =
            Time.current - RECENT_ACTIVITY_WINDOW

          entities
            .select do |entity|
              entity.updated_at.present? &&
                entity.updated_at >= cutoff
            end
            .sort_by(&:updated_at)
            .reverse
            .first(25)
        end

        def entity_signals(entity, relationship_count)
          signals = []

          if relationship_count.zero?
            signals << {
              key: "isolated",
              severity: "warning",
              label: "Isolated entity",
              description:
                "No discovered ecosystem relationships exist yet."
            }
          end

          if safe_health_score(entity) < 70
            signals << {
              key: "health",
              severity: "critical",
              label: "Quality attention",
              description:
                "Entity health is below the review threshold."
            }
          end

          if entity.respond_to?(:workflow_state) &&
              entity.workflow_state.to_s == "review"
            signals << {
              key: "review",
              severity: "warning",
              label: "Review opportunity",
              description:
                "Entity is currently waiting in the editorial review state."
            }
          end

          if entity.updated_at.present? &&
              entity.updated_at < STALE_AFTER.ago
            signals << {
              key: "stale",
              severity: "warning",
              label: "Stale entity",
              description:
                "Entity has not been updated recently."
            }
          end

          if relationship_count >= 5
            signals << {
              key: "hub",
              severity: "info",
              label: "Ecosystem hub",
              description:
                "Entity is connected to multiple other entities."
            }
          end

          signals
        end
      end
    end
  end
end
