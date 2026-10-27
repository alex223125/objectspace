
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_query_validator.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphQueryValidator
            STATES = %w[suggested confirmed rejected archived].freeze

            def initialize(parameters)
              @parameters = parameters.to_h.stringify_keys
            end

            def call
              errors = {}

              depth = integer_value("depth", default: 1)
              limit = integer_value("limit", default: 100)

              errors[:depth] = "must be between 1 and 3" unless (1..3).cover?(depth)
              errors[:limit] = "must be between 1 and 500" unless (1..500).cover?(limit)

              state = @parameters["state"].to_s
              if state.present? && !STATES.include?(state)
                errors[:state] = "is not a supported relationship state"
              end

              {
                valid: errors.empty?,
                errors: errors,
                values: {
                  depth: depth,
                  limit: limit,
                  state: state.presence
                }
              }
            end

            private

            def integer_value(key, default:)
              raw = @parameters[key]
              return default if raw.nil? || raw.to_s.empty?

              Integer(raw, 10)
            rescue ArgumentError, TypeError
              default
            end
          end
        end
      end
    end
  end
end