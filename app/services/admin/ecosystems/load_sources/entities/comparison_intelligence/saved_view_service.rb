
# frozen_string_literal: true

require "securerandom"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class SavedViewService
            CACHE_PREFIX = "comparison_intelligence:saved_views"
            CACHE_TTL = 30.days

            ALLOWED_FILTERS = %w[
              type
              risk
              reviewed
              path
              query
              sort
              direction
            ].freeze

            def initialize(user:, cache: Rails.cache)
              @user = user
              @cache = cache
            end

            def list
              records.values.sort_by do |view|
                view.fetch("updated_at", "")
              end.reverse
            end

            def find(id)
              records[id.to_s]
            end

            def create(name:, filters: {}, layout: {})
              label = name.to_s.strip
              raise ArgumentError, "Name is required" if label.blank?
              raise ArgumentError, "Name is too long" if label.length > 100

              id = SecureRandom.uuid
              timestamp = Time.current.iso8601

              view = {
                "id" => id,
                "name" => label,
                "filters" => sanitize_filters(filters),
                "layout" => sanitize_layout(layout),
                "created_at" => timestamp,
                "updated_at" => timestamp
              }

              write_record(id, view)
              view
            end

            def update(id:, name: nil, filters: nil, layout: nil)
              view = find(id)
              raise KeyError, "Saved view not found" unless view

              updated = view.deep_dup
              updated["name"] = name.to_s.strip if name.present?
              updated["filters"] = sanitize_filters(filters) if filters
              updated["layout"] = sanitize_layout(layout) if layout
              updated["updated_at"] = Time.current.iso8601

              raise ArgumentError, "Name is too long" if updated["name"].length > 100
              raise ArgumentError, "Name is required" if updated["name"].blank?

              write_record(id.to_s, updated)
              updated
            end

            def destroy(id:)
              existing = find(id)
              return false unless existing

              updated = records.except(id.to_s)
              persist(updated)
              true
            end

            private

            def records
              @cache.read(cache_key).presence || {}
            end

            def write_record(id, record)
              updated = records.merge(id => record)
              persist(updated)
            end

            def persist(value)
              @cache.write(cache_key, value, expires_in: CACHE_TTL)
            end

            def cache_key
              user_id = @user&.id
              raise ArgumentError, "Authenticated user required" unless user_id

              "#{CACHE_PREFIX}:#{user_id}"
            end

            def sanitize_filters(filters)
              source = filters.to_h.stringify_keys
              source.slice(*ALLOWED_FILTERS).transform_values do |value|
                value.is_a?(String) ? value.truncate(300) : value
              end
            end

            def sanitize_layout(layout)
              source = layout.to_h.stringify_keys
              source.slice("density", "visible_sections", "chart_mode")
            end
          end
        end
      end
    end
  end
end