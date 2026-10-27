
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_serialization_service.rb

require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphSerializationService
            ALLOWED_FORMATS = %w[json].freeze

            def initialize(payload)
              @payload = payload
            end

            def call(format: "json")
              raise ArgumentError, "Unsupported format" unless
                ALLOWED_FORMATS.include?(format.to_s)

              JSON.generate(
                normalize(@payload),
                max_nesting: 50,
                allow_nan: false
              )
            end

            private

            def normalize(value)
              case value
              when Hash
                value.each_with_object({}) do |(key, item), result|
                  result[key.to_s] = normalize(item)
                end
              when Array
                value.map { |item| normalize(item) }
              when Time, ActiveSupport::TimeWithZone
                value.iso8601
              when BigDecimal
                value.to_s("F")
              when String, Numeric, TrueClass, FalseClass, NilClass
                value
              else
                value.respond_to?(:as_json) ? normalize(value.as_json) : value.to_s
              end
            end
          end
        end
      end
    end
  end
end