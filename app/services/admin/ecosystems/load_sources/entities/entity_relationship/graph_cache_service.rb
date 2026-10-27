
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_cache_service.rb

require "digest"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphCacheService
            DEFAULT_TTL = 5.minutes

            def initialize(namespace: "relationship_graph", ttl: DEFAULT_TTL)
              @namespace = namespace.to_s
              @ttl = ttl
            end

            def fetch(key, expires_in: @ttl, &block)
              raise ArgumentError, "A cache block is required" unless block

              Rails.cache.fetch(cache_key(key), expires_in: expires_in, &block)
            end

            def delete(key)
              Rails.cache.delete(cache_key(key))
            end

            def clear
              # Rails cache stores do not all support namespace deletion.
              # Prefer versioned keys or targeted deletes in production.
              false
            end

            def self.fingerprint(parameters)
              Digest::SHA256.hexdigest(JSON.generate(deep_sort(parameters)))
            end

            def self.deep_sort(value)
              case value
              when Hash
                value.keys.sort.each_with_object({}) do |key, result|
                  result[key] = deep_sort(value[key])
                end
              when Array
                value.map { |item| deep_sort(item) }
              else
                value
              end
            end

            private

            def cache_key(key)
              "#{@namespace}:v1:#{key}"
            end
          end
        end
      end
    end
  end
end