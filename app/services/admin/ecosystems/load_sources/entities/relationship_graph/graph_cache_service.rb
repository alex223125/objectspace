
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_cache_service.rb

require "digest"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphCacheService
            DEFAULT_TTL = 5.minutes
            MAX_TTL = 1.hour
            CACHE_NAMESPACE = "objectspace/relationship_graph/v1"

            def initialize(cache: Rails.cache, ttl: DEFAULT_TTL)
              @cache = cache
              @ttl = [[ttl.to_i, 1].max, MAX_TTL.to_i].min.seconds
            end

            def fetch(key:, version: nil, expires_in: nil, &block)
              raise ArgumentError, "A cache key is required" if key.blank?
              raise ArgumentError, "A block is required" unless block

              cache_key = build_key(key, version)

              @cache.fetch(
                cache_key,
                expires_in: bounded_ttl(expires_in)
              ) do
                block.call
              end
            end

            def read(key:, version: nil)
              @cache.read(build_key(key, version))
            end

            def write(key:, value:, version: nil, expires_in: nil)
              @cache.write(
                build_key(key, version),
                value,
                expires_in: bounded_ttl(expires_in)
              )
            end

            def delete(key:, version: nil)
              @cache.delete(build_key(key, version))
            end

            # Use a new version after graph data changes to avoid stale reads.
            def build_key(key, version = nil)
              digest = Digest::SHA256.hexdigest(
                [key.to_s, version.to_s].join(":")
              )

              "#{CACHE_NAMESPACE}/#{digest}"
            end

            private

            def bounded_ttl(value)
              requested = value ? value.to_i : @ttl.to_i
              requested = [[requested, 1].max, MAX_TTL.to_i].min
              requested.seconds
            end
          end
        end
      end
    end
  end
end