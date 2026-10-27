# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipCandidateService
            def initialize(limit: 50, entity_type_id: nil)
              @limit = [[limit.to_i, 1].max, 200].min
              @entity_type_id = entity_type_id
            end

            def call
              entities = entity_scope.limit(500).to_a
              relationships = relationship_model.unscoped
                                                .pluck(:source_entity_id, :target_entity_id)

              existing = relationships.each_with_object({}) do |(source, target), result|
                next if source.nil? || target.nil?

                result[[source, target]] = true
                result[[target, source]] = true
              end

              candidates = []

              entities.combination(2) do |left, right|
                next if existing[[left.id, right.id]]

                candidates << {
                  source_id: left.id,
                  source_name: left.name,
                  target_id: right.id,
                  target_name: right.name,
                  reason: shared_type?(left, right) ? "shared_entity_type" : "cohort_candidate",
                  state: "candidate"
                }

                break if candidates.size >= @limit
              end

              {
                candidates: candidates,
                count: candidates.size,
                generated_from: "bounded_entity_cohort",
                note: "Candidates are suggestions, not evidence of a real relationship."
              }
            end

            private

            def entity_scope
              scope = entity_model.unscoped.order(:id)
              scope = scope.where(entity_type_id: @entity_type_id) if @entity_type_id.present?
              scope
            end

            def shared_type?(left, right)
              left.entity_type_id.present? &&
                left.entity_type_id == right.entity_type_id
            end

            def entity_model
              ::Ecosystems::LoadSources::Entity::Entity
            end

            def relationship_model
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            end
          end
        end
      end
    end
  end
end