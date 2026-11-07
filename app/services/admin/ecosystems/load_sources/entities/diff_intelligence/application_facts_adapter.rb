# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationFactsAdapter
          TYPE_MAP = {
            changed: :content_change,
            content_change: :content_change,

            moved: :semantic_movement,
            semantic_movement: :semantic_movement,

            added: :added_entity,
            added_entity: :added_entity,

            removed: :removed_entity,
            removed_entity: :removed_entity,

            ambiguous: :identity_warning,
            duplicate_identity: :identity_warning,
            missing_identity: :identity_warning,
            identity_warning: :identity_warning
          }.freeze

          def self.call(source)
            new.call(source)
          end

          def call(source)
            return source if source.is_a?(ApplicationFacts)

            ApplicationFacts.new(
              facts: extract_facts(source)
            )
          end

          private

          def extract_facts(source)
            raw_facts =
              if source.respond_to?(:facts)
                source.facts
              elsif source.respond_to?(:semantic_facts)
                source.semantic_facts
              elsif source.respond_to?(:to_semantic_facts)
                source.to_semantic_facts
              elsif source.is_a?(Array)
                source
              else
                raise ArgumentError,
                      "Cannot extract semantic facts from #{source.class}"
              end

            Array(raw_facts).map do |fact|
              convert_fact(fact)
            end
          end

          def convert_fact(fact)
            return fact if fact.is_a?(ApplicationFact)

            unless fact.respond_to?(:to_h)
              raise ArgumentError,
                    "Cannot convert #{fact.class} into an application fact"
            end

            hash = fact.to_h

            raw_type =
              value_from(hash, :type) ||
                infer_type(fact)

            ApplicationFact.new(
              type: normalize_type(raw_type),
              path: value_from(hash, :path) || [],
              old_value: value_from(hash, :old_value),
              new_value: value_from(hash, :new_value),
              identity: value_from(hash, :identity),
              old_index: value_from(hash, :old_index),
              new_index: value_from(hash, :new_index),
              metadata: value_from(hash, :metadata) || {}
            )
          end

          def value_from(hash, key)
            return hash[key] if hash.key?(key)

            string_key = key.to_s

            return hash[string_key] if hash.key?(string_key)

            nil
          end

          def normalize_type(type)
            normalized = type.to_sym

            TYPE_MAP.fetch(
              normalized,
              normalized
            )
          rescue NoMethodError
            raise ArgumentError,
                  "Unknown semantic fact type: #{type.inspect}"
          end

          def infer_type(fact)
            if fact.respond_to?(:content_change?) &&
              fact.content_change?
              :content_change
            elsif fact.respond_to?(:semantic_movement?) &&
              fact.semantic_movement?
              :semantic_movement
            elsif fact.respond_to?(:added_entity?) &&
              fact.added_entity?
              :added_entity
            elsif fact.respond_to?(:removed_entity?) &&
              fact.removed_entity?
              :removed_entity
            elsif fact.respond_to?(:identity_warning?) &&
              fact.identity_warning?
              :identity_warning
            else
              raise ArgumentError,
                    "Cannot determine semantic fact type from #{fact.class}"
            end
          end
        end
      end
    end
  end
end