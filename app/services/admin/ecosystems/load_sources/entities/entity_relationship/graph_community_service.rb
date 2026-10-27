# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_community_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphCommunityService
            Entity =
              ::Ecosystems::LoadSources::Entity::Entity

            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize(limit: 2_000)
              @limit = [[limit.to_i, 1].max, 10_000].min
            end

            def call
              ids = Entity.unscoped.order(:id).limit(@limit).pluck(:id)
              edges = Relationship.unscoped
                                  .where(state: "confirmed")
                                  .where(source_entity_id: ids, target_entity_id: ids)
                                  .pluck(:source_entity_id, :target_entity_id)

              adjacency = ids.index_with { [] }
              edges.each do |source, target|
                adjacency[source] << target
                adjacency[target] << source
              end

              visited = {}
              communities = []

              ids.each do |start|
                next if visited[start]

                stack = [start]
                members = []
                visited[start] = true

                until stack.empty?
                  current = stack.pop
                  members << current

                  adjacency.fetch(current, []).each do |neighbor|
                    next if visited[neighbor]

                    visited[neighbor] = true
                    stack << neighbor
                  end
                end

                communities << members.sort
              end

              communities.sort_by! { |members| [-members.size, members.first || 0] }

              {
                algorithm: "connected_components",
                community_count: communities.size,
                communities: communities.each_with_index.map do |members, index|
                  { id: index + 1, size: members.size, entity_ids: members }
                end,
                sampled: ids.size >= @limit
              }
            end
          end
        end
      end
    end
  end
end