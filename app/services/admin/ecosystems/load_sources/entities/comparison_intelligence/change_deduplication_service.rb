
# frozen_string_literal: true

require "digest"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ChangeDeduplicationService
            def call(changes)
              seen = {}

              Array(changes).each_with_object([]) do |change, result|
                attributes = change.to_h.deep_symbolize_keys
                fingerprint = fingerprint_for(attributes)

                next if seen.key?(fingerprint)

                seen[fingerprint] = true
                result << attributes
              end
            end

            private

            def fingerprint_for(attributes)
              payload = {
                path: attributes[:path].to_s,
                type: attributes[:type].to_s,
                before: attributes[:before],
                after: attributes[:after],
                relationship_identity: attributes[:relationship_identity]
              }

              Digest::SHA256.hexdigest(
                JSON.generate(canonicalize(payload))
              )
            end

            def canonicalize(value)
              case value
              when Hash
                value.each_with_object({}) do |(key, child), result|
                  result[key.to_s] = canonicalize(child)
                end.sort.to_h
              when Array
                value.map { |child| canonicalize(child) }
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