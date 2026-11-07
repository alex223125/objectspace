# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class ApplicationDiffPresenter
        def self.call(diff)
          new(diff).call
        end

        def initialize(diff)
          @diff = diff
        end

        def call
          {
            summary: summary,
            changes: serialize_facts(diff.changes),
            movements: serialize_facts(diff.movements),
            additions: serialize_facts(diff.additions),
            removals: serialize_facts(diff.removals),
            warnings: serialize_facts(diff.warnings),
            total: diff.total
          }
        end

        private

        attr_reader :diff

        def summary
          {
            total: diff.total,
            changes: diff.changes.length,
            movements: diff.movements.length,
            additions: diff.additions.length,
            removals: diff.removals.length,
            warnings: diff.warnings.length
          }
        end

        def serialize_facts(facts)
          Array(facts).map do |fact|
            serialize_fact(fact)
          end
        end

        def serialize_fact(fact)
          {
            type: fact.type.to_s,
            path: Array(fact.path).map(&:to_s),
            identity: fact.respond_to?(:identity) ? fact.identity : nil,
            old_index:
              fact.respond_to?(:old_index) ?
                fact.old_index :
                nil,
            new_index:
              fact.respond_to?(:new_index) ?
                fact.new_index :
                nil,
            old_value: fact.old_value,
            new_value: fact.new_value,
            metadata: normalize_value(fact.metadata)
          }
        end

        def normalize_value(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, child), result|
              result[key.to_s] =
                normalize_value(child)
            end

          when Array
            value.map do |child|
              normalize_value(child)
            end

          else
            value
          end
        end
      end
    end
  end
end