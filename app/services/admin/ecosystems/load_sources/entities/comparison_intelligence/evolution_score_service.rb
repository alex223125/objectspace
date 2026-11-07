
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class EvolutionScoreService
            def call(changes:, reviewed_count: 0)
              items = Array(changes)
              total = items.length

              counts = items.each_with_object(Hash.new(0)) do |item, result|
                type = read(item, :type).to_s
                result[type] += 1
              end

              volume = [total * 2, 25].min
              additions = [counts["added"] * 3, 20].min
              removals = [counts["removed"] * 3, 20].min
              movement = [counts["moved"] * 4, 15].min
              review = total.zero? ? 0 :
                         [(reviewed_count.to_f / total * 20).round, 20].min

              score = [volume + additions + removals + movement + review, 100].min

              {
                score: score,
                level: level_for(score),
                components: {
                  change_volume: volume,
                  additions: additions,
                  removals: removals,
                  movement: movement,
                  review_completion: review
                },
                explanation: explanation(score, total, reviewed_count)
              }
            end

            private

            def read(item, key)
              item.respond_to?(:[]) ? (item[key] || item[key.to_s]) : nil
            end

            def level_for(score)
              case score
              when 0..19 then "quiet"
              when 20..39 then "emerging"
              when 40..59 then "active"
              when 60..79 then "substantial"
              else "transformative"
              end
            end

            def explanation(score, total, reviewed)
              return "No changes were detected." if total.zero?

              "#{total} changes detected; #{reviewed} reviewed. " \
                "Evolution score: #{score}/100."
            end
          end
        end
      end
    end
  end
end