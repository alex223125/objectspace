
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class AchievementService
            ACHIEVEMENTS = [
              {
                id: "first_review",
                title: "First Steps",
                description: "Review your first comparison change.",
                icon: "🌱",
                threshold: 1,
                metric: :reviewed_changes
              },
              {
                id: "ten_reviews",
                title: "Focused Reviewer",
                description: "Review 10 comparison changes.",
                icon: "🔎",
                threshold: 10,
                metric: :reviewed_changes
              },
              {
                id: "fifty_reviews",
                title: "Knowledge Steward",
                description: "Review 50 comparison changes.",
                icon: "📚",
                threshold: 50,
                metric: :reviewed_changes
              },
              {
                id: "complete_review",
                title: "Review Complete",
                description: "Review every change in a comparison.",
                icon: "🏆",
                threshold: 100,
                metric: :completion_percentage
              }
            ].freeze

            def initialize(metrics: {})
              @metrics = metrics.to_h.symbolize_keys
            end

            def call
              ACHIEVEMENTS.map do |achievement|
                value = metric_value(achievement[:metric])
                threshold = achievement[:threshold]

                {
                  id: achievement[:id],
                  title: achievement[:title],
                  description: achievement[:description],
                  icon: achievement[:icon],
                  progress: [[value, 0].max, threshold].min,
                  threshold: threshold,
                  unlocked: value >= threshold,
                  percentage: threshold.zero? ? 100 : [
                    ((value.to_f / threshold) * 100).round,
                    100
                  ].min
                }
              end
            end

            private

            def metric_value(metric)
              value = @metrics.fetch(metric, 0)
              Float(value || 0)
            rescue ArgumentError, TypeError
              0.0
            end
          end
        end
      end
    end
  end
end