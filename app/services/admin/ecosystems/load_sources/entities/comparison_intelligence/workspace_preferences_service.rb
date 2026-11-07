
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class WorkspacePreferencesService
            CACHE_PREFIX = "comparison_intelligence:preferences"
            CACHE_TTL = 180.days

            DEFAULTS = {
              "density" => "comfortable",
              "default_tab" => "overview",
              "chart_mode" => "visual",
              "reduced_motion" => false,
              "show_tooltips" => true,
              "show_guidance" => true,
              "visible_sections" => [
                "overview",
                "changes",
                "risk",
                "evidence",
                "review"
              ]
            }.freeze

            DENSITIES = %w[comfortable spacious].freeze
            DEFAULT_TABS = %w[
              overview changes risk evidence review history
            ].freeze
            CHART_MODES = %w[visual compact].freeze

            def initialize(user:, cache: Rails.cache)
              @user = user
              @cache = cache
            end

            def call
              DEFAULTS.deep_dup.merge(read_preferences)
            end

            def update(attributes:)
              incoming = attributes.to_h.stringify_keys
              preferences = call

              preferences["density"] = incoming["density"] if
                DENSITIES.include?(incoming["density"])

              preferences["default_tab"] = incoming["default_tab"] if
                DEFAULT_TABS.include?(incoming["default_tab"])

              preferences["chart_mode"] = incoming["chart_mode"] if
                CHART_MODES.include?(incoming["chart_mode"])

              %w[reduced_motion show_tooltips show_guidance].each do |key|
                next unless incoming.key?(key)

                preferences[key] =
                  ActiveModel::Type::Boolean.new.cast(incoming[key])
              end

              if incoming["visible_sections"].is_a?(Array)
                preferences["visible_sections"] =
                  incoming["visible_sections"].map(&:to_s).uniq.first(20)
              end

              @cache.write(
                cache_key,
                preferences,
                expires_in: CACHE_TTL
              )

              preferences
            end

            private

            def read_preferences
              return {} unless @user&.id

              value = @cache.read(cache_key)
              value.is_a?(Hash) ? value.stringify_keys : {}
            end

            def cache_key
              raise ArgumentError, "Authenticated user required" unless @user&.id

              "#{CACHE_PREFIX}:#{@user.id}"
            end
          end
        end
      end
    end
  end
end