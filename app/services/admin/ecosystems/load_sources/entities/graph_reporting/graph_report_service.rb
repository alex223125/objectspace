
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module GraphReporting
          class GraphReportService
            DEFAULT_LIMIT = 100
            MAX_LIMIT = 500

            def initialize(limit: DEFAULT_LIMIT, filters: {})
              @limit = [[limit.to_i, 1].max, MAX_LIMIT].min
              @filters = filters.to_h.symbolize_keys
            end

            def call
              relationships = relationship_scope
              entities = entity_model
              entity_count = safe_count(entities.all)

              {
                generated_at: Time.current.iso8601,
                summary: {
                  entity_count: entity_count,
                  relationship_count: safe_count(relationships),
                  confirmed_relationship_count: count_by_status(relationships, "confirmed"),
                  candidate_relationship_count: count_by_status(relationships, "candidate"),
                  limit: @limit
                },
                relationships: relationships.limit(@limit).map do |relationship|
                  serialize_relationship(relationship)
                end,
                warnings: schema_warnings
              }
            end

            private

            def relationship_model
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            end

            def entity_model
              ::Ecosystems::LoadSources::Entity::Entity
            end

            def relationship_scope
              scope = relationship_model.all
              columns = relationship_model.column_names

              status_column = %w[status state review_status].find do |column|
                columns.include?(column)
              end

              if status_column && @filters[:status].present?
                scope = scope.where(status_column => @filters[:status].to_s)
              end

              scope
            end

            def count_by_status(scope, value)
              column = %w[status state review_status].find do |candidate|
                relationship_model.column_names.include?(candidate)
              end

              return nil unless column

              scope.where(column => value).count
            end

            def serialize_relationship(record)
              record.attributes.slice(
                "id", "status", "state", "review_status",
                "source_entity_id", "target_entity_id",
                "from_entity_id", "to_entity_id",
                "relationship_type", "relation_type",
                "created_at", "updated_at"
              )
            end

            def safe_count(scope)
              scope.count
            rescue ActiveRecord::StatementInvalid
              nil
            end

            def schema_warnings
              warnings = []
              columns = relationship_model.column_names

              unless (columns & %w[status state review_status]).any?
                warnings << "No recognized relationship review-status column exists."
              end

              unless (columns & %w[source_entity_id from_entity_id]).any?
                warnings << "No recognized source-entity foreign key was detected."
              end

              warnings
            end
          end
        end
      end
    end
  end
end