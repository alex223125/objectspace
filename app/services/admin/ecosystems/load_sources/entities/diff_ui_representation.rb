# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class DiffUIRepresentation
        TYPE_ORDER = {
          "identity_warning" => 0,
          "removed_entity" => 1,
          "semantic_movement" => 2,
          "content_change" => 3,
          "added_entity" => 4
        }.freeze

        attr_reader(
          :summary,
          :changes,
          :movements,
          :additions,
          :removals,
          :warnings
        )

        def self.call(diff)
          new(diff).call
        end

        def initialize(diff)
          @diff = diff
        end

        def call
          facts =
            normalized_facts

          ui_facts =
            facts
              .map { |fact| build_ui_fact(fact) }
              .sort_by { |fact| sort_key(fact) }

          @changes =
            ui_facts.select(&:content_change?).freeze

          @movements =
            ui_facts.select(&:semantic_movement?).freeze

          @additions =
            ui_facts.select(&:added_entity?).freeze

          @removals =
            ui_facts.select(&:removed_entity?).freeze

          @warnings =
            ui_facts.select(&:identity_warning?).freeze

          @summary =
            build_summary(ui_facts).freeze

          freeze
        end

        def total
          summary[:total]
        end

        def empty?
          total.zero?
        end

        def facts
          (
            changes +
              movements +
              additions +
              removals +
              warnings
          ).sort_by { |fact| sort_key(fact) }
        end

        def to_h
          {
            summary: summary,
            changes: changes.map(&:to_h),
            movements: movements.map(&:to_h),
            additions: additions.map(&:to_h),
            removals: removals.map(&:to_h),
            warnings: warnings.map(&:to_h)
          }
        end

        def as_json(*)
          to_h
        end

        private

        attr_reader :diff

        def normalized_facts
          if diff.respond_to?(:facts)
            Array(diff.facts)
          elsif diff.respond_to?(:to_h)
            hash = diff.to_h

            Array(
              hash[:facts] ||
                hash["facts"]
            )
          else
            []
          end
        end

        def build_ui_fact(fact)
          attributes =
            fact_attributes(fact)

          DiffUIFact.new(
            type: attributes[:type],
            path: attributes[:path],
            identity: attributes[:identity],
            old_index: attributes[:old_index],
            new_index: attributes[:new_index],
            old_value: attributes[:old_value],
            new_value: attributes[:new_value],
            metadata: attributes[:metadata]
          )
        end

        def fact_attributes(fact)
          source =
            if fact.respond_to?(:to_h)
              fact.to_h
            elsif fact.respond_to?(:as_json)
              fact.as_json
            else
              {}
            end

          source =
            source.respond_to?(:to_h) ?
              source.to_h :
              {}

          {
            type:
              source[:type] ||
                source["type"],

            path:
              source[:path] ||
                source["path"],

            identity:
              source[:identity] ||
                source["identity"],

            old_index:
              if source.key?(:old_index)
                source[:old_index]
              else
                source["old_index"]
              end,

            new_index:
              if source.key?(:new_index)
                source[:new_index]
              else
                source["new_index"]
              end,

            old_value:
              if source.key?(:old_value)
                source[:old_value]
              else
                source["old_value"]
              end,

            new_value:
              if source.key?(:new_value)
                source[:new_value]
              else
                source["new_value"]
              end,

            metadata:
              source[:metadata] ||
                source["metadata"] ||
                {}
          }
        end

        def build_summary(facts)
          {
            total: facts.length,
            changes: facts.count(&:content_change?),
            movements: facts.count(&:semantic_movement?),
            additions: facts.count(&:added_entity?),
            removals: facts.count(&:removed_entity?),
            warnings: facts.count(&:identity_warning?),
            has_changes: facts.any?,
            has_warnings: facts.any?(&:identity_warning?)
          }
        end

        def sort_key(fact)
          [
            fact.path_string,
            TYPE_ORDER.fetch(fact.type, 99),
            fact.identity.to_s,
            fact.old_index.nil? ? -1 : fact.old_index,
            fact.new_index.nil? ? -1 : fact.new_index,
            stable_value(fact.old_value),
            stable_value(fact.new_value),
            stable_value(fact.metadata)
          ]
        end

        def stable_value(value)
          case value
          when Hash
            value
              .keys
              .map(&:to_s)
              .sort
              .map do |key|
              child =
                if value.key?(key)
                  value[key]
                else
                  value[key.to_sym]
                end

              "#{key}=#{stable_value(child)}"
            end
              .join("|")

          when Array
            value
              .map { |item| stable_value(item) }
              .join("|")

          else
            value.to_s
          end
        end
      end
    end
  end
end