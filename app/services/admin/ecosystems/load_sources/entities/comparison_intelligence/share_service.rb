
# frozen_string_literal: true

require "securerandom"
require "digest"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ShareService
            CACHE_PREFIX = "comparison_intelligence:shares"
            DEFAULT_TTL = 7.days
            MAX_TTL = 30.days

            def initialize(user:, cache: Rails.cache)
              @user = user
              @cache = cache
            end

            def create(comparison_id:, permissions: ["read"], expires_in: DEFAULT_TTL)
              raise ArgumentError, "Authenticated user required" unless @user&.id

              ttl = [[expires_in.to_i, 60].max, MAX_TTL.to_i].min
              allowed = Array(permissions).map(&:to_s) & %w[read export]

              token = SecureRandom.urlsafe_base64(32)
              key = token_key(token)

              record = {
                "comparison_id" => comparison_id.to_s,
                "owner_id" => @user.id.to_s,
                "permissions" => allowed.presence || ["read"],
                "created_at" => Time.current.iso8601,
                "expires_at" => (Time.current + ttl.seconds).iso8601
              }

              @cache.write(key, record, expires_in: ttl.seconds)

              {
                token: token,
                expires_at: record["expires_at"],
                permissions: record["permissions"]
              }
            end

            def resolve(token:)
              return unless token.present?

              record = @cache.read(token_key(token))
              return unless record.is_a?(Hash)

              return if Time.iso8601(record.fetch("expires_at")) <= Time.current

              record
            rescue ArgumentError, KeyError
              nil
            end

            def revoke(token:)
              return false unless @user&.id

              key = token_key(token)
              record = @cache.read(key)

              return false unless record
              return false unless record["owner_id"].to_s == @user.id.to_s

              @cache.delete(key)
              true
            end

            private

            def token_key(token)
              digest = Digest::SHA256.hexdigest(token.to_s)
              "#{CACHE_PREFIX}:#{digest}"
            end
          end
        end
      end
    end
  end
end