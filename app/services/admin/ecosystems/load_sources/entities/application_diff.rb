
# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class ApplicationDiff
        TYPE_ORDER = {
          identity_warning: 0,
          removed_entity: 1,
          semantic_movement: 2,
          content_change: 3,
          added_entity: 4
        }.freeze unless const_defined?(:TYPE_ORDER, false)

        unless const_defined?(:Result, false)
          Result = Struct.new(
            :summary,
            :changes,
            :movements,
            :additions,
            :removals,
            :warnings,
            :facts,
            keyword_init: true
          ) do
            include Enumerable

            def empty?
              facts.empty?
            end

            def total
              facts.length
            end

            def changed?
              total.positive?
            end

            def to_a
              facts
            end

            def each(&block)
              facts.each(&block)
            end

            def [](index)
              facts[index]
            end

            def to_h
              {
                summary: summary,
                changes: changes.map(&:to_h),
                movements: movements.map(&:to_h),
                additions: additions.map(&:to_h),
                removals: removals.map(&:to_h),
                warnings: warnings.map(&:to_h),
                facts: facts.map(&:to_h)
              }
            end

            def as_json(*)
              to_h
            end
          end
        end

        class << self
          def call(facts:)
            new(facts).call
          end
        end

        def initialize(facts)
          @facts = normalize_facts(facts)
        end

        def call
          Result.new(
            summary: build_summary,
            changes: changes,
            movements: movements,
            additions: additions,
            removals: removals,
            warnings: warnings,
            facts: facts
          )
        end

        private

        attr_reader :facts

        def normalize_facts(source)
          normalized =
            case source
            when Array
              source
            else
              if source.respond_to?(:to_a)
                source.to_a
              else
                [source]
              end
            end

          normalized
            .compact
            .map { |fact| normalize_fact(fact) }
            .sort_by { |fact| sort_key(fact) }
            .freeze
        end

        def normalize_fact(fact)
          return fact if semantic_fact?(fact)

          attributes =
            if fact.respond_to?(:to_h)
              fact.to_h
            elsif fact.respond_to?(:as_json)
              fact.as_json
            else
              raise ArgumentError,
                    "Unsupported application diff fact: #{fact.class}"
            end

          attributes = attributes.to_h

          fetch_attribute = lambda do |key, default = nil|
            if attributes.key?(key)
              attributes[key]
            elsif attributes.key?(key.to_s)
              attributes[key.to_s]
            else
              default
            end
          end

          fact_class =
            Ecosystems::LoadSources::Entity::
                DiffIntelligence::ApplicationSemanticFact

          fact_class.new(
            type: fetch_attribute.call(:type),
            path: fetch_attribute.call(:path),
            old_value: fetch_attribute.call(:old_value),
            new_value: fetch_attribute.call(:new_value),
            metadata: fetch_attribute.call(:metadata, {})
          )
        end

        def semantic_fact?(fact)
          fact_class =
            Ecosystems::LoadSources::Entity::
                DiffIntelligence::ApplicationSemanticFact

          fact.is_a?(fact_class)
        rescue NameError
          false
        end

        def changes
          @changes ||= facts.select(&:content_change?).freeze
        end

        def movements
          @movements ||= facts.select(&:semantic_movement?).freeze
        end

        def additions
          @additions ||= facts.select(&:added_entity?).freeze
        end

        def removals
          @removals ||= facts.select(&:removed_entity?).freeze
        end

        def warnings
          @warnings ||= facts.select(&:identity_warning?).freeze
        end

        def build_summary
          {
            total: facts.length,
            changed: changes.length,
            moved: movements.length,
            added: additions.length,
            removed: removals.length,
            warnings: warnings.length,
            has_changes: facts.any?
          }.freeze
        end

        def sort_key(fact)
          [
            Array(fact.path).map(&:to_s).join("\0"),
            TYPE_ORDER.fetch(fact.type, 99),
            stable_value(fact.old_value),
            stable_value(fact.new_value),
            stable_value(fact.metadata)
          ]
        end

        def stable_value(value)
          case value
          when Hash
            value.keys
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
            value.map { |item| stable_value(item) }.join("|")
          else
            value.to_s
          end
        end
      end
    end
  end
end