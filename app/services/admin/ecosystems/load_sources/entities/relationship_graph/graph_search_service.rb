
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphSearchService
            DEFAULT_LIMIT = 50
            MAX_LIMIT = 500
            MAX_QUERY_LENGTH = 200

            def initialize(nodes:, query:, limit: DEFAULT_LIMIT)
              @nodes = Array(nodes)
              @query = query.to_s.strip.downcase
              @limit = normalize_limit(limit)
            end

            def call
              validate_query!

              return @nodes.first(@limit) if @query.blank?

              @nodes.select do |node|
                searchable_values(node).any? do |value|
                  value.downcase.include?(@query)
                end
              end.first(@limit)
            end

            private

            def searchable_values(node)
              %i[
                id name slug summary description entity_type
                entity_type_id status workflow_state
              ].filter_map do |field|
                value = read(node, field)
                value.to_s if value.present?
              end
            end

            def read(node, field)
              if node.respond_to?(:key?)
                return node[field] if node.key?(field)
                return node[field.to_s] if node.key?(field.to_s)
              end

              node.public_send(field) if node.respond_to?(field)
            end

            def validate_query!
              if @query.length > MAX_QUERY_LENGTH
                raise ArgumentError,
                      "query must not exceed #{MAX_QUERY_LENGTH} characters"
              end
            end

            def normalize_limit(value)
              limit = Integer(value.to_s, 10)

              unless limit.between?(1, MAX_LIMIT)
                raise ArgumentError,
                      "limit must be between 1 and #{MAX_LIMIT}"
              end

              limit
            rescue ArgumentError, TypeError
              raise ArgumentError, "invalid search limit"
            end
          end
        end
      end
    end
  end
end