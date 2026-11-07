# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class DiffUIPayload
          SCHEMA_VERSION = 1

      Result = Struct.new(
        :schema_version,
        :summary,
        :changes,
        :movements,
        :additions,
        :removals,
        :warnings,
        keyword_init: true
      ) do
        def to_h
          {
            schema_version: schema_version,
            summary: summary,
            changes: changes,
            movements: movements,
            additions: additions,
            removals: removals,
            warnings: warnings
          }
        end

        def as_json(*)
          to_h
        end
      end

      def self.call(diff:)
        new(diff: diff).call
      end

      def initialize(diff:)
        @diff = diff
      end

      def call
        Result.new(
          schema_version: SCHEMA_VERSION,
          summary: normalize_summary,
          changes: serialize_facts(diff.changes),
          movements: serialize_facts(diff.movements),
          additions: serialize_facts(diff.additions),
          removals: serialize_facts(diff.removals),
          warnings: serialize_facts(diff.warnings)
        )
      end

      private

      attr_reader :diff

      def normalize_summary
        summary =
          if diff.respond_to?(:summary)
            diff.summary
          else
            {}
          end

        summary =
          summary.respond_to?(:to_h) ?
            summary.to_h :
            {}

        {
          total: integer_value(summary[:total] || summary["total"]),
          changed: integer_value(summary[:changed] || summary["changed"]),
          moved: integer_value(summary[:moved] || summary["moved"]),
          added: integer_value(summary[:added] || summary["added"]),
          removed: integer_value(summary[:removed] || summary["removed"]),
          warnings: integer_value(summary[:warnings] || summary["warnings"]),
          semantic_changes:
            integer_value(
              summary[:semantic_changes] ||
                summary["semantic_changes"]
            ),
          unchanged:
            integer_value(
              summary[:unchanged] ||
                summary["unchanged"]
            )
        }
      end

      def serialize_facts(facts)
        Array(facts).map do |fact|
          serialize_fact(fact)
        end
      end

      def serialize_fact(fact)
        {
          type: fact.type,
          path: Array(fact.path).map(&:to_s),
          identity: fact.identity,
          old_value: deep_copy(fact.old_value),
          new_value: deep_copy(fact.new_value),
          old_index: fact.old_index,
          new_index: fact.new_index,
          metadata: deep_copy(fact.metadata)
        }
      end

      def deep_copy(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, child), result|
            result[key.to_s] = deep_copy(child)
          end

        when Array
          value.map do |child|
            deep_copy(child)
          end

        else
          value
        end
      end

      def integer_value(value)
        return 0 if value.nil?

        Integer(value)
      rescue ArgumentError, TypeError
        0
      end
    end
  end
end

        end
      end
