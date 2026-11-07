
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphQueryService
            DEFAULT_LIMIT = 100
            MAX_LIMIT = 500
            DEFAULT_DEPTH = 1
            MAX_DEPTH = 4

            def initialize(
              entity_scope:,
              relationship_scope: nil,
              params: {},
              source_column: :source_entity_id,
              target_column: :target_entity_id
            )
              @entity_scope = entity_scope
              @relationship_scope = relationship_scope
              @params = params.to_h.with_indifferent_access
              @source_column = source_column.to_sym
              @target_column = target_column.to_sym
            end

            def call
              validate_scope!(@entity_scope)

              limit = bounded_integer(
                @params[:limit], DEFAULT_LIMIT, 1, MAX_LIMIT
              )

              depth = bounded_integer(
                @params[:depth], DEFAULT_DEPTH, 0, MAX_DEPTH
              )

              query = @params[:query].to_s.strip
              raise ArgumentError, "query is too long" if query.length > 200

              entities = @entity_scope
              entities = apply_entity_search(entities, query) if query.present?
              entities = entities.limit(limit + 1)

              records = entities.to_a
              truncated = records.length > limit
              records = records.first(limit)

              edges = load_edges(records)

              GraphPayloadService.new(
                nodes: records,
                edges: edges,
                meta: {
                  limit: limit,
                  depth: depth,
                  truncated: truncated,
                  states: Array(@params[:states]).presence
                }
              ).call
            end

            private

            def validate_scope!(scope)
              unless scope.respond_to?(:where) &&
                scope.respond_to?(:limit) &&
                scope.respond_to?(:klass)
                raise ArgumentError,
                      "entity_scope must be an ActiveRecord relation"
              end
            end

            def bounded_integer(value, default, minimum, maximum)
              return default if value.blank?

              integer = Integer(value.to_s, 10)

              unless integer.between?(minimum, maximum)
                raise ArgumentError,
                      "value must be between #{minimum} and #{maximum}"
              end

              integer
            rescue ArgumentError, TypeError
              raise ArgumentError, "invalid integer parameter"
            end

            def apply_entity_search(scope, query)
              columns = scope.klass.column_names
              searchable = %w[name slug summary].select do |column|
                columns.include?(column)
              end

              return scope if searchable.empty?

              pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"

              conditions = searchable.map do |column|
                "#{scope.klass.connection.quote_table_name(scope.klass.table_name)}." \
                  "#{scope.klass.connection.quote_column_name(column)} ILIKE :query"
              end

              scope.where(conditions.join(" OR "), query: pattern)
            end

            def load_edges(nodes)
              return [] unless @relationship_scope.respond_to?(:where)
              return [] if nodes.empty?

              validate_scope!(@relationship_scope)

              columns = @relationship_scope.klass.column_names
              unless columns.include?(@source_column.to_s) &&
                columns.include?(@target_column.to_s)
                raise ArgumentError,
                      "relationship endpoint columns are not configured correctly"
              end

              ids = nodes.map(&:id)

              @relationship_scope
                .where(@source_column => ids)
                .or(@relationship_scope.where(@target_column => ids))
                .limit(MAX_LIMIT * 4)
                .to_a
            end
          end
        end
      end
    end
  end
end