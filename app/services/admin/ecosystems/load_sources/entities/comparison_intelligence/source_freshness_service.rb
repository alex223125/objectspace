
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class SourceFreshnessService
            DEFAULT_MAX_AGE_DAYS = 365

            def initialize(sources:, reference_time: Time.current, max_age_days: DEFAULT_MAX_AGE_DAYS)
              @sources = Array(sources)
              @reference_time = reference_time
              @max_age_days = [max_age_days.to_i, 1].max
            end

            def call
              items = sources.map do |source|
                data = normalize(source)
                published_at = parse_time(data[:published_at])
                checked_at = parse_time(data[:checked_at])
                effective_time = checked_at || published_at

                age_days =
                  effective_time ? [(reference_time.to_date - effective_time.to_date).to_i, 0].max : nil

                status =
                  if effective_time.nil?
                    "unknown"
                  elsif effective_time > reference_time
                    "future_dated"
                  elsif age_days <= max_age_days / 4
                    "fresh"
                  elsif age_days <= max_age_days
                    "aging"
                  else
                    "stale"
                  end

                {
                  id: data[:id],
                  title: data[:title],
                  age_days: age_days,
                  status: status,
                  published_at: published_at&.iso8601,
                  checked_at: checked_at&.iso8601
                }
              end

              known = items.select { |item| item[:age_days] }
              average_age = known.empty? ? nil : (known.sum { |item| item[:age_days] }.to_f / known.length).round

              {
                total: items.length,
                fresh: items.count { |item| item[:status] == "fresh" },
                aging: items.count { |item| item[:status] == "aging" },
                stale: items.count { |item| item[:status] == "stale" },
                unknown: items.count { |item| item[:status] == "unknown" },
                average_age_days: average_age,
                sources: items
              }
            end

            private

            attr_reader :sources, :reference_time, :max_age_days

            def normalize(source)
              data = source.respond_to?(:to_h) ? source.to_h : {}
              data = data.stringify_keys

              {
                id: data["id"],
                title: data["title"] || data["name"],
                published_at: data["published_at"] || data["publication_date"],
                checked_at: data["checked_at"] || data["last_verified_at"]
              }
            end

            def parse_time(value)
              return if value.blank?

              value.respond_to?(:to_time) ? value.to_time : Time.zone.parse(value.to_s)
            rescue ArgumentError, TypeError
              nil
            end
          end
        end
      end
    end
  end
end