
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ComparisonOrchestrator
            def initialize(
              context:,
              changes:,
              cache: ComparisonCache.new,
              fingerprint: ComparisonFingerprint.new
            )
              @context = context
              @changes = Array(changes)
              @cache = cache
              @fingerprint = fingerprint
            end

            def call
              cache_key = fingerprint.call(
                changes: changes,
                attributes: context.cache_attributes
              )

              result = cache.fetch(cache_key) do
                calculate_result
              end

              result.is_a?(ComparisonResult) ? result : ComparisonResult.new(result)
            end

            private

            attr_reader :context, :changes, :cache, :fingerprint

            def calculate_result
              intelligence =
                Admin::Ecosystems::LoadSources::Entities::
                    ComparisonIntelligence
                  .new(changes: changes)
                  .call

              query =
                ComparisonQuery.new(
                  changes: changes,
                  context: context
                ).call

              intelligence.merge(
                filtered_changes: query[:changes],
                filtered_total: query[:total],
                pagination: query.except(
                  :changes,
                  :filters,
                  :available_types,
                  :available_risks
                ),
                filters: query[:filters],
                available_types: query[:available_types],
                available_risks: query[:available_risks]
              )
            end
          end
        end
      end
    end
  end
end