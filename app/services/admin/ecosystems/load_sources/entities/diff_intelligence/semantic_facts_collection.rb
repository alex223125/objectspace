# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFactsCollection
          include Enumerable

          def initialize(facts = [])
            @facts = Array(facts).map do |fact|
              normalize_fact(fact)
            end
          end

          def each(&block)
            @facts.each(&block)
          end

          def to_a
            @facts.dup
          end

          def size
            @facts.size
          end

          alias_method :count, :size

          def empty?
            @facts.empty?
          end

          def added
            select(&:added?)
          end

          def removed
            select(&:removed?)
          end

          def changed
            select(&:changed?)
          end

          def moved
            select(&:moved?)
          end

          def unchanged
            select(&:unchanged?)
          end

          def meaningful_changes
            select(&:meaningful_change?)
          end

          def status_counts
            {
              added: added.size,
              removed: removed.size,
              changed: changed.size,
              moved: moved.size,
              unchanged: unchanged.size
            }
          end

          def paths
            map(&:path)
          end

          def to_h
            {
              facts: map(&:to_h),
              counts: status_counts
            }
          end

          private

          def normalize_fact(fact)
            return fact if fact.is_a?(SemanticFacts)

            SemanticFacts.new(
              path: fact.fetch(:path),
              status: fact.fetch(:status),
              old_value: fact[:old_value],
              new_value: fact[:new_value],
              identity: fact[:identity],
              metadata: fact[:metadata] || {}
            )
          end
        end
      end
    end
  end
end