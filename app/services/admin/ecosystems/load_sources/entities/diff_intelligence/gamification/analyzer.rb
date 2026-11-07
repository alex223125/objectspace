# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        module Gamification
          class Analyzer
            def self.call(result:)
              new(result: result).call
            end

            def initialize(result:)
              @result = result
            end

            def call
              facts = normalize_result(@result)

              {
                summary: build_summary(facts),
                signals: build_signals(facts),
                progress: build_progress(facts),
                badges: build_badges(facts),
                metadata: {
                  engine: "diff_intelligence",
                  gamification: "semantic_facts",
                  version: 1
                }
              }
            end

            private

            attr_reader :result

            def normalize_result(value)
              return {} if value.nil?

              if value.respond_to?(:to_h)
                value.to_h
              else
                {}
              end
            end

            def build_summary(facts)
              changes = Array(facts[:changes] || facts["changes"])

              counts = {
                added: 0,
                removed: 0,
                changed: 0,
                unchanged: 0,
                moved: 0,
                conflicts: 0
              }

              changes.each do |change|
                type = change_type(change)

                case type
                when "added"
                  counts[:added] += 1
                when "removed"
                  counts[:removed] += 1
                when "changed"
                  counts[:changed] += 1
                when "unchanged"
                  counts[:unchanged] += 1
                when "moved"
                  counts[:moved] += 1
                when "duplicate", "ambiguous", "identity_conflict"
                  counts[:conflicts] += 1
                end
              end

              counts.merge(
                total: changes.length,
                meaningful_changes:
                  counts[:added] +
                    counts[:removed] +
                    counts[:changed] +
                    counts[:moved]
              )
            end

            def build_signals(facts)
              summary = build_summary(facts)

              signals = []

              if summary[:moved].positive?
                signals << {
                  key: "movement_detected",
                  type: "movement",
                  title: "Movement detected",
                  description: "#{summary[:moved]} item(s) changed position.",
                  level: "info",
                  icon: "↔️",
                  color: "sky"
                }
              end

              if summary[:changed].positive?
                signals << {
                  key: "semantic_changes",
                  type: "change",
                  title: "Semantic changes detected",
                  description: "#{summary[:changed]} item(s) contain changed values.",
                  level: "active",
                  icon: "⚡",
                  color: "violet"
                }
              end

              if summary[:added].positive?
                signals << {
                  key: "new_items",
                  type: "addition",
                  title: "New items discovered",
                  description: "#{summary[:added]} item(s) were added.",
                  level: "positive",
                  icon: "✨",
                  color: "emerald"
                }
              end

              if summary[:removed].positive?
                signals << {
                  key: "removed_items",
                  type: "removal",
                  title: "Items removed",
                  description: "#{summary[:removed]} item(s) were removed.",
                  level: "attention",
                  icon: "−",
                  color: "orange"
                }
              end

              if summary[:conflicts].positive?
                signals << {
                  key: "identity_conflicts",
                  type: "identity",
                  title: "Identity attention required",
                  description: "#{summary[:conflicts]} identity issue(s) require review.",
                  level: "warning",
                  icon: "⚠️",
                  color: "amber"
                }
              end

              if signals.empty?
                signals << {
                  key: "stable_comparison",
                  type: "stable",
                  title: "Comparison is stable",
                  description: "No semantic changes were detected.",
                  level: "success",
                  icon: "✓",
                  color: "emerald"
                }
              end

              signals
            end

            def build_progress(facts)
              summary = build_summary(facts)

              total = summary[:total]

              if total.zero?
                return {
                  score: 100,
                  level: "stable",
                  label: "Ready",
                  description: "No comparable changes were found."
                }
              end

              meaningful = summary[:meaningful_changes]

              stability = ((total - meaningful).to_f / total * 100).round
              stability = stability.clamp(0, 100)

              level =
                case stability
                when 90..100 then "mastered"
                when 70..89 then "strong"
                when 40..69 then "developing"
                else "active"
                end

              {
                score: stability,
                level: level,
                label: progress_label(level),
                description: progress_description(level)
              }
            end

            def build_badges(facts)
              summary = build_summary(facts)
              badges = []

              if summary[:moved].positive?
                badges << {
                  key: "movement_tracker",
                  name: "Movement Tracker",
                  description: "Detected structural movement instead of treating reordered items as simple changes.",
                  icon: "↔️",
                  color: "sky",
                  rarity: "common"
                }
              end

              if summary[:changed].positive?
                badges << {
                  key: "semantic_detector",
                  name: "Semantic Detector",
                  description: "Detected meaningful value-level changes.",
                  icon: "🔎",
                  color: "violet",
                  rarity: "common"
                }
              end

              if summary[:added].positive?
                badges << {
                  key: "ecosystem_growth",
                  name: "Ecosystem Growth",
                  description: "Detected newly introduced items.",
                  icon: "🌱",
                  color: "emerald",
                  rarity: "common"
                }
              end

              if summary[:conflicts].positive?
                badges << {
                  key: "identity_guardian",
                  name: "Identity Guardian",
                  description: "Detected an identity conflict requiring attention.",
                  icon: "🛡️",
                  color: "amber",
                  rarity: "rare"
                }
              end

              if badges.empty?
                badges << {
                  key: "clean_scan",
                  name: "Clean Scan",
                  description: "The comparison contains no semantic changes.",
                  icon: "✨",
                  color: "emerald",
                  rarity: "common"
                }
              end

              badges
            end

            def change_type(change)
              return "" unless change.respond_to?(:[])

              value =
                change[:type] ||
                  change["type"] ||
                  change[:status] ||
                  change["status"]

              value.to_s.downcase
            end

            def progress_label(level)
              {
                "mastered" => "Semantic Mastery",
                "strong" => "Strong Semantic Signal",
                "developing" => "Developing Intelligence",
                "active" => "Active Comparison"
              }.fetch(level, "Active Comparison")
            end

            def progress_description(level)
              {
                "mastered" => "The comparison is highly stable.",
                "strong" => "Most compared structures remain stable.",
                "developing" => "Several semantic changes were detected.",
                "active" => "The comparison contains substantial change activity."
              }.fetch(level, "Semantic comparison is active.")
            end
          end
        end
      end
    end
  end
end