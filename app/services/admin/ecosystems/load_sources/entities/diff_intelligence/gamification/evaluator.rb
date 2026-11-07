# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        module Gamification
          class Evaluator
            def initialize(result)
              @result = result
            end

            def call
              signals = []

              add_change_signals(signals)
              add_movement_signals(signals)
              add_identity_signals(signals)
              add_stability_signals(signals)

              GamificationResult.new(
                signals: signals
              )
            end

            private

            attr_reader :result

            def add_change_signals(signals)
              result.facts.changed.each do |fact|
                signals << Signal.new(
                  type: "change",
                  key: "field_changed",
                  title: "Change detected",
                  description: "#{fact.path} changed.",
                  points: 5,
                  severity: "info",
                  metadata: {
                    path: fact.path
                  }
                )
              end

              result.facts.added.each do |fact|
                signals << Signal.new(
                  type: "addition",
                  key: "field_added",
                  title: "New content discovered",
                  description: "#{fact.path} was added.",
                  points: 3,
                  severity: "positive",
                  metadata: {
                    path: fact.path
                  }
                )
              end

              result.facts.removed.each do |fact|
                signals << Signal.new(
                  type: "removal",
                  key: "field_removed",
                  title: "Content removed",
                  description: "#{fact.path} was removed.",
                  points: 2,
                  severity: "warning",
                  metadata: {
                    path: fact.path
                  }
                )
              end
            end

            def add_movement_signals(signals)
              result.facts.moved.each do |fact|
                signals << Signal.new(
                  type: "movement",
                  key: "item_moved",
                  title: "Structure evolved",
                  description: "#{fact.path} moved position.",
                  points: 8,
                  severity: "positive",
                  metadata: {
                    path: fact.path,
                    identity: fact.identity
                  }
                )
              end
            end

            def add_identity_signals(signals)
              identity_facts =
                result.facts.select do |fact|
                  fact.metadata["identity"] ||
                    fact.metadata[:identity]
                end

              return if identity_facts.empty?

              signals << Signal.new(
                type: "identity",
                key: "identity_matching",
                title: "Identity-aware comparison",
                description: "The comparison used semantic item identity.",
                points: 10,
                severity: "positive",
                metadata: {
                  matched_items: identity_facts.size
                }
              )
            end

            def add_stability_signals(signals)
              unchanged_count = result.unchanged_count
              meaningful_count = result.facts.meaningful_changes.size

              return if unchanged_count.zero?
              return if meaningful_count.zero?

              signals << Signal.new(
                type: "stability",
                key: "stable_structure",
                title: "Stable structure detected",
                description: "#{unchanged_count} comparison node(s) remained unchanged.",
                points: 1,
                severity: "info",
                metadata: {
                  unchanged_count: unchanged_count
                }
              )
            end
          end
        end
      end
    end
  end
end