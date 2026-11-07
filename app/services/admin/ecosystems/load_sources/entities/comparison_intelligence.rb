
# frozen_string_literal: true

require "securerandom"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          CHANGE_TYPES = %w[
            changed
            moved
            added
            removed
            warning
          ].freeze

          RISK_LEVELS = %w[
            low
            medium
            high
            critical
          ].freeze

          def initialize(changes:)
            @changes = normalize_changes(changes)
          end

          def call
            {
              total_changes: changes.length,
              reviewed_changes: reviewed_count,
              remaining_changes: [
                changes.length - reviewed_count,
                0
              ].max,

              change_density: change_density,
              evolution_score: evolution_score,

              type_breakdown: type_breakdown,
              path_breakdown: path_breakdown,

              attention: attention_items,
              highlights: highlights,

              movement: movement_metrics,
              balance: balance_metrics
            }
          end

          private

          attr_reader :changes

          def normalize_changes(items)
            Array(items).map do |item|
              attributes =
                if item.respond_to?(:to_h)
                  item.to_h.stringify_keys
                else
                  {}
                end

              {
                id: attributes["id"].presence || SecureRandom.hex(6),
                type: normalize_type(attributes["type"]),
                path: attributes["path"].presence || "Unknown path",
                reviewed: ActiveModel::Type::Boolean.new.cast(
                  attributes["reviewed"]
                ),
                risk: normalize_risk(attributes["risk"]),
                magnitude: normalize_magnitude(
                  attributes["magnitude"]
                )
              }
            end
          end

          def normalize_type(type)
            value = type.to_s.downcase

            CHANGE_TYPES.include?(value) ? value : "changed"
          end

          def normalize_risk(risk)
            value = risk.to_s.downcase

            RISK_LEVELS.include?(value) ? value : "low"
          end

          def normalize_magnitude(value)
            number = value.to_i

            return 1 if number < 1

            [number, 100].min
          end

          def reviewed_count
            changes.count { |change| change[:reviewed] }
          end

          def type_breakdown
            CHANGE_TYPES.index_with do |type|
              changes.count { |change| change[:type] == type }
            end
          end

          def path_breakdown
            changes
              .group_by { |change| change[:path] }
              .transform_values(&:length)
              .sort_by { |_path, count| -count }
              .first(8)
              .to_h
          end

          def change_density
            return 0 if changes.empty?

            density = changes.sum { |change| change[:magnitude] }

            [[density, 100].min, 0].max
          end

          def evolution_score
            return 0 if changes.empty?

            score = 0

            score += [changes.length * 4, 35].min
            score += [
              changes.count { |change| change[:type] == "added" } * 3,
              15
            ].min
            score += [
              changes.count { |change| change[:type] == "moved" } * 4,
              15
            ].min
            score += [
              changes.count { |change| change[:type] == "warning" } * 5,
              20
            ].min
            score += [change_density / 10, 10].min

            [[score, 100].min, 0].max
          end

          def attention_items
            items = []

            critical = changes.count do |change|
              change[:risk] == "critical"
            end

            high = changes.count do |change|
              change[:risk] == "high"
            end

            warnings = changes.count do |change|
              change[:type] == "warning"
            end

            if critical.positive?
              items << {
                level: "critical",
                title: "Critical changes detected",
                description:
                  "#{critical} critical change#{'s' unless critical == 1} require immediate review.",
                count: critical
              }
            end

            if high.positive?
              items << {
                level: "high",
                title: "High-risk changes detected",
                description:
                  "#{high} high-risk change#{'s' unless high == 1} deserve focused review.",
                count: high
              }
            end

            if warnings.positive?
              items << {
                level: "warning",
                title: "Identity warnings present",
                description:
                  "#{warnings} warning#{'s' unless warnings == 1} may affect interpretation.",
                count: warnings
              }
            end

            if changes.any? && reviewed_count.zero?
              items << {
                level: "info",
                title: "Review has not started",
                description:
                  "Begin with the highest-attention changes first.",
                count: changes.length
              }
            end

            items.first(5)
          end

          def highlights
            [
              biggest_change,
              most_active_path,
              dominant_change_type,
              review_progress
            ].compact
          end

          def biggest_change
            change = changes.max_by do |item|
              item[:magnitude]
            end

            return unless change

            {
              key: "biggest_change",
              icon: "⚡",
              title: "Largest detected change",
              value: change[:path],
              meta: "#{change[:magnitude]} impact points"
            }
          end

          def most_active_path
            path, count = path_breakdown.first

            return unless path

            {
              key: "most_active_path",
              icon: "🎯",
              title: "Most active path",
              value: path,
              meta: "#{count} change#{'s' unless count == 1}"
            }
          end

          def dominant_change_type
            type, count = type_breakdown.max_by do |_key, value|
              value
            end

            return if count.to_i.zero?

            {
              key: "dominant_type",
              icon: icon_for_type(type),
              title: "Dominant evolution pattern",
              value: type.capitalize,
              meta: "#{count} occurrence#{'s' unless count == 1}"
            }
          end

          def review_progress
            return unless changes.any?

            percentage =
              ((reviewed_count.to_f / changes.length) * 100).round

            {
              key: "review_progress",
              icon: "🧭",
              title: "Review progress",
              value: "#{percentage}%",
              meta: "#{reviewed_count}/#{changes.length} reviewed"
            }
          end

          def movement_metrics
            moved = changes.count do |change|
              change[:type] == "moved"
            end

            {
              count: moved,
              percentage: percentage(moved)
            }
          end

          def balance_metrics
            breakdown = type_breakdown

            {
              additions: breakdown.fetch("added", 0),
              removals: breakdown.fetch("removed", 0),
              changed: breakdown.fetch("changed", 0),
              moved: breakdown.fetch("moved", 0),
              warnings: breakdown.fetch("warning", 0)
            }
          end

          def percentage(value)
            return 0 if changes.empty?

            ((value.to_f / changes.length) * 100).round
          end

          def icon_for_type(type)
            {
              "changed" => "🟠",
              "moved" => "🟣",
              "added" => "🟢",
              "removed" => "🔴",
              "warning" => "🟡"
            }.fetch(type, "⚪")
          end
        end
      end
    end
  end
end