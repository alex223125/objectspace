# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
      class ApplicationDiff
        TYPES = %i[
          content_change
          semantic_movement
          added_entity
          removed_entity
          identity_warning
        ].freeze

        CATEGORY_ORDER = {
          content_change: 0,
          semantic_movement: 1,
          added_entity: 2,
          removed_entity: 3,
          identity_warning: 4
        }.freeze

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
          def total
            summary[:total]
          end

          def changed
            summary[:changed]
          end

          def moved
            summary[:moved]
          end

          def added
            summary[:added]
          end

          def removed
            summary[:removed]
          end

          def warning_count
            summary[:warnings]
          end

          def empty?
            facts.empty?
          end

          def size
            facts.size
          end

          alias_method :length, :size

          def each(&block)
            facts.each(&block)
          end

          def [](index)
            facts[index]
          end

          def to_a
            facts.dup
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
        end

        def self.call(facts:)
          new(facts: facts).call
        end

        def initialize(facts:)
          @facts = facts
        end

        def call
          normalized_facts =
            normalize_facts(@facts)

          Result.new(
            summary: build_summary(normalized_facts),
            changes: freeze_array(
              facts_for(normalized_facts, :content_change)
            ),
            movements: freeze_array(
              facts_for(normalized_facts, :semantic_movement)
            ),
            additions: freeze_array(
              facts_for(normalized_facts, :added_entity)
            ),
            removals: freeze_array(
              facts_for(normalized_facts, :removed_entity)
            ),
            warnings: freeze_array(
              facts_for(normalized_facts, :identity_warning)
            ),
            facts: freeze_array(normalized_facts)
          )
        end

        private

        def normalize_facts(source)
          application_facts =
            normalize_source(source)

          application_facts
            .sort_by { |fact| sort_key(fact) }
            .freeze
        end

        def normalize_source(source)
          if source.nil?
            return []
          end

          if source.is_a?(
            ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFacts
          )
            return source.to_a
          end

          if source.respond_to?(:facts) &&
            !source.is_a?(
              ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFact
            )

            return normalize_source(source.facts)
          end

          Array(source).flat_map do |item|
            normalize_item(item)
          end
        end

        def normalize_item(item)
          if item.is_a?(
            ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFact
          )
            return [item]
          end

          if item.is_a?(
            ::Ecosystems::LoadSources::Entity::DiffIntelligence::SemanticFact
          )
            return [
              convert_semantic_fact(item)
            ]
          end

          if item.respond_to?(:to_h)
            return [
              convert_hash(item.to_h)
            ]
          end

          if item.respond_to?(:type)
            return [
              convert_object(item)
            ]
          end

          raise ArgumentError,
                "Unsupported application diff fact: #{item.class.name}"
        end

        def convert_semantic_fact(fact)
          ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFact.new(
            type: fact.type,
            path: fact.path,
            old_value: fact.old_value,
            new_value: fact.new_value,
            metadata: build_metadata(fact)
          )
        end

        def convert_object(object)
          ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFact.new(
            type: object.type,
            path:
              object.respond_to?(:path) ?
                object.path :
                [],
            old_value:
              object.respond_to?(:old_value) ?
                object.old_value :
                nil,
            new_value:
              object.respond_to?(:new_value) ?
                object.new_value :
                nil,
            metadata:
              object.respond_to?(:metadata) ?
                object.metadata :
                {}
          )
        end

        def convert_hash(value)
          hash =
            symbolize_keys(value)

          ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFact.new(
            type:
              hash[:type],

            path:
              hash[:path],

            old_value:
              hash[:old_value],

            new_value:
              hash[:new_value],

            metadata:
              hash[:metadata] || {}
          )
        end

        def build_metadata(fact)
          metadata =
            if fact.respond_to?(:metadata)
              fact.metadata
            else
              {}
            end

          metadata =
            metadata.respond_to?(:to_h) ?
              metadata.to_h :
              {}

          metadata =
            metadata.each_with_object({}) do |(key, value), result|
              result[key.to_s] = value
            end

          if fact.respond_to?(:identity) &&
            fact.identity.present?

            metadata["identity"] =
              fact.identity
          end

          if fact.respond_to?(:old_index) &&
            !fact.old_index.nil?

            metadata["old_index"] =
              fact.old_index
          end

          if fact.respond_to?(:new_index) &&
            !fact.new_index.nil?

            metadata["new_index"] =
              fact.new_index
          end

          metadata
        end

        def facts_for(facts, type)
          facts.select do |fact|
            fact.type == type
          end
        end

        def build_summary(facts)
          summary = {
            total: facts.length,
            changed: 0,
            moved: 0,
            added: 0,
            removed: 0,
            warnings: 0
          }

          facts.each do |fact|
            case fact.type
            when :content_change
              summary[:changed] += 1

            when :semantic_movement
              summary[:moved] += 1

            when :added_entity
              summary[:added] += 1

            when :removed_entity
              summary[:removed] += 1

            when :identity_warning
              summary[:warnings] += 1
            end
          end

          summary.freeze
        end

        def sort_key(fact)
          [
            fact.path.map(&:to_s).join("\0"),
            CATEGORY_ORDER.fetch(fact.type, 99),
            stable_value(fact.old_value),
            stable_value(fact.new_value),
            stable_metadata(fact.metadata)
          ]
        end

        def stable_metadata(metadata)
          stable_value(metadata)
        end

        def stable_value(value)
          case value
          when Hash
            value
              .keys
              .map(&:to_s)
              .sort
              .map do |key|
              original_key =
                if value.key?(key)
                  key
                else
                  key.to_sym
                end

              "#{key}=#{stable_value(value[original_key])}"
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

        def symbolize_keys(value)
          return {} unless value.respond_to?(:each)

          value.each_with_object({}) do |(key, item), result|
            result[key.to_sym] = item
          end
        end

        def freeze_array(value)
          value.to_a.freeze
        end
      end
    end
  end
  end
end
