
# app/services/admin/ecosystems/load_sources/entities/graph_reporting/graph_comparison_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module GraphReporting
          class GraphComparisonService
            Entity = ::Ecosystems::LoadSources::Entity::Entity
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize(from:, to:)
              @from = parse_time(from)
              @to = parse_time(to)
              raise ArgumentError, "from must be before to" unless @from < @to
            end

            def call
              {
                from: @from.iso8601,
                to: @to.iso8601,
                entities_created: Entity.unscoped
                                        .where(created_at: @from...@to).count,
                relationships_created: Relationship.unscoped
                                                   .where(created_at: @from...@to).count,
                relationships_confirmed: Relationship.unscoped
                                                     .where(state: "confirmed", updated_at: @from...@to).count,
                relationships_rejected: Relationship.unscoped
                                                    .where(state: "rejected", updated_at: @from...@to).count,
                note: "Confirmation and rejection counts use updated_at, not a complete state history."
              }
            end

            private

            def parse_time(value)
              Time.zone.parse(value.to_s) ||
                raise(ArgumentError, "Invalid comparison timestamp")
            end
          end
        end
      end
    end
  end
end