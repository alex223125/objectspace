
# frozen_string_literal: true

require "bigdecimal"
require "date"
require "time"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class CanonicalValueNormalizer
            def call(value, field: nil, definition: {})
              normalized = normalize(value)

              if definition[:type] == :text && normalized.is_a?(String)
                normalized.strip
              else
                normalized
              end
            end

            private

            def normalize(value)
              case value
              when Hash
                value.each_with_object({}) do |(key, child), result|
                  result[key.to_s] = normalize(child)
                end.sort.to_h
              when Array
                value.map { |child| normalize(child) }
              when String
                value.encode("UTF-8", invalid: :replace, undef: :replace)
                     .gsub(/\r\n?/, "\n")
              when Symbol
                value.to_s
              when BigDecimal
                value.to_s("F")
              when Time, DateTime
                value.iso8601(6)
              when Date
                value.iso8601
              else
                value
              end
            rescue Encoding::CompatibilityError
              value.to_s
            end
          end
        end
      end
    end
  end
end