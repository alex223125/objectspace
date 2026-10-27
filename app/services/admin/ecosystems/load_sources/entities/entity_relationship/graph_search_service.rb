
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_search_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphSearchService
            Entity = ::Ecosystems::LoadSources::Entity::Entity

            def initialize(query:, limit: 25, status: nil)
              @query = query.to_s.strip.first(200)
              @limit = [[limit.to_i, 1].max, 100].min
              @status = status.to_s.presence
            end

            def call
              return { query: @query, results: [] } if @query.blank?

              scope = Entity.unscoped.where(
                "name ILIKE :q OR slug ILIKE :q OR summary ILIKE :q",
                q: "%#{escape_like(@query)}%"
              )

              scope = scope.where(status: @status) if @status

              results = scope.order(:name, :id).limit(@limit).map do |entity|
                {
                  id: entity.id,
                  name: entity.name,
                  slug: entity.slug,
                  summary: entity.summary,
                  status: entity.status
                }
              end

              { query: @query, results: results }
            end

            private

            def escape_like(value)
              value.gsub(/[\\%_]/) { |character| "\\#{character}" }
            end
          end
        end
      end
    end
  end
end