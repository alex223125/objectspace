
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ComparisonCache
            DEFAULT_EXPIRY = 5.minutes

            def initialize(enabled: true, expires_in: DEFAULT_EXPIRY)
              @enabled = enabled
              @expires_in = expires_in
            end

            def fetch(key, &block)
              return block.call unless enabled?
              return block.call unless defined?(Rails) && Rails.respond_to?(:cache)

              Rails.cache.fetch(
                namespaced_key(key),
                expires_in: expires_in,
                race_condition_ttl: 2.seconds,
                &block
              )
            rescue StandardError => error
              report_cache_error(error)
              block.call
            end

            def delete(key)
              return false unless defined?(Rails) && Rails.respond_to?(:cache)

              Rails.cache.delete(namespaced_key(key))
            rescue StandardError => error
              report_cache_error(error)
              false
            end

            private

            attr_reader :enabled, :expires_in

            def enabled?
              enabled && !Rails.env.test?
            rescue StandardError
              enabled
            end

            def namespaced_key(key)
              "admin:comparison-intelligence:v1:#{key}"
            end

            def report_cache_error(error)
              return unless defined?(Rails) && Rails.respond_to?(:logger)

              Rails.logger.warn(
                "[ComparisonIntelligence::Cache] #{error.class}: #{error.message}"
              )
            end
          end
        end
      end
    end
  end
end