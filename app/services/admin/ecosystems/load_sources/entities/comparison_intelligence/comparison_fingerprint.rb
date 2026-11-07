
# frozen_string_literal: true

require "digest"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ComparisonFingerprint
            VERSION = "v1"

            def call(changes:, attributes: {})
              payload = {
                version: VERSION,
                changes: canonicalize(changes),
                attributes: canonicalize(attributes)
              }

              Digest::SHA256.hexdigest(JSON.generate(payload))
            end

            private

            def canonicalize(value)
              case value
              when Hash
                value
                  .each_with_object({}) do |(key, child), result|
                  result[key.to_s] = canonicalize(child)
                end
                  .sort
                  .to_h
              when Array
                value.map { |child| canonicalize(child) }
              when Symbol
                value.to_s
              when Time, DateTime, Date
                value.iso8601
              when BigDecimal
                value.to_s("F")
              else
                if value.respond_to?(:as_json) &&
                  !value.is_a?(String) &&
                  !value.is_a?(Numeric) &&
                  !value.is_a?(TrueClass) &&
                  !value.is_a?(FalseClass) &&
                  !value.nil?
                  canonicalize(value.as_json)
                else
                  value
                end
              end
            end
          end
        end
      end
    end
  end
end