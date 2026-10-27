# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphCentralityService
            def initialize(limit: 2_000, top: 50)
              @limit = [[limit.to_i, 1].max, 10_000].min
              @top = [[top.to_i, 1].max, 200].min
            end

            def call
              entity_model =
                ::Ecosystems::LoadSources::Entity::Entity

              relationship_model =
                ::Ecosystems::LoadSources::Entity::EntityRelationship

              entities = entity_model.unscoped.order(:id).limit(@limit).to_a
              ids = entities.map(&:id)

              edges = relationship_model.unscoped
                                         .where(state: "confirmed")
                                         .where(
                                           source_entity_id: ids,
                                           target_entity_id: ids
                                         )
                                         .pluck(
                                           :source_entity_id,
                                           :target_entity_id
                                         )

              degrees = ids.index_with { 0 }

              edges.each do |source, target|
                degrees[source] += 1 if degrees.key?(source)
                degrees[target] += 1 if degrees.key?(target)
              end

              maximum = [ids.size - 1, 1].max

              ranked = entities.map do |entity|
                degree = degrees.fetch(entity.id, 0)

                {
                  entity_id: entity.id,
                  name: entity.name.presence || "Entity ##{entity.id}",
                  degree: degree,
                  degree_centrality: (degree.to_f / maximum).round(5)
                }
              end

              {
                metric: "degree_centrality",
                ranked_entities: ranked.sort_by do |row|
                  [-row[:degree], row[:entity_id]]
                end.first(@top),
                sampled: entities.size >= @limit
              }
            end
          end
        end
      end
    end
  end
end
