
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_export_service.rb

require "csv"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphExportService
            Entity = ::Ecosystems::LoadSources::Entity::Entity
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize(limit: 500, state: nil)
              @limit = [[limit.to_i, 1].max, 2_000].min
              @state = state.to_s.presence
            end

            def call(format: :json)
              entities = Entity.unscoped.order(:id).limit(@limit).to_a
              ids = entities.map(&:id)

              scope = Relationship.unscoped.where(
                source_entity_id: ids, target_entity_id: ids
              )
              scope = scope.where(state: @state) if @state
              edges = scope.order(:id).limit(10_000).to_a

              case format.to_s
              when "csv"
                export_csv(entities, edges)
              when "json"
                export_json(entities, edges)
              else
                raise ArgumentError, "Unsupported export format"
              end
            end

            private

            def export_json(entities, edges)
              {
                generated_at: Time.current.iso8601,
                truncated: entities.size >= @limit,
                nodes: entities.map do |entity|
                  { id: entity.id, name: entity.name, slug: entity.slug }
                end,
                edges: edges.map do |edge|
                  {
                    id: edge.id,
                    source: edge.source_entity_id,
                    target: edge.target_entity_id,
                    kind: edge.relationship_kind,
                    state: edge.state,
                    confidence: edge.confidence
                  }
                end
              }.to_json
            end

            def export_csv(_entities, edges)
              CSV.generate(headers: true) do |csv|
                csv << %w[
                  relationship_id source_entity_id target_entity_id
                  relationship_kind state confidence
                ]

                edges.each do |edge|
                  csv << [
                    edge.id, edge.source_entity_id, edge.target_entity_id,
                    edge.relationship_kind, edge.state, edge.confidence
                  ]
                end
              end
            end
          end
        end
      end
    end
  end
end