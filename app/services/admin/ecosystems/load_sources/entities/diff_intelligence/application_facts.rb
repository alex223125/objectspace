# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationFacts
          TYPE_ORDER = {
            added_entity: 0,
            removed_entity: 1,
            semantic_movement: 2,
            content_change: 3,
            identity_warning: 4
          }.freeze

          attr_reader :facts

          def self.call(result:)
            new(result: result).call
          end

          def initialize(result:)
            @result = result
          end

          def call
            @facts =
              extract_facts
                .map { |fact| normalize_fact(fact) }
                .sort_by { |fact| sort_key(fact) }
                .freeze

            self
          end

          def to_a
            facts.map(&:to_h)
          end

          def to_h
            {
              facts: to_a
            }
          end

          def as_json(*)
            to_h
          end

          private

          attr_reader :result

          def extract_facts
            if result.respond_to?(:semantic_facts)
              return Array(result.semantic_facts)
            end

            if result.respond_to?(:facts)
              return Array(result.facts)
            end

            if result.is_a?(Hash)
              return Array(
                result[:semantic_facts] ||
                  result["semantic_facts"] ||
                  result[:facts] ||
                  result["facts"]
              )
            end

            []
          end

          def normalize_fact(fact)
            return fact if fact.is_a?(ApplicationFact)

            unless fact.respond_to?(:to_h)
              raise ArgumentError,
                    "Unsupported semantic fact: #{fact.inspect}"
            end

            hash = fact.to_h

            ApplicationFact.new(
              type:
                fetch_value(hash, :type),

              path:
                fetch_value(hash, :path) || [],

              old_value:
                fetch_value(hash, :old_value),

              new_value:
                fetch_value(hash, :new_value),

              metadata:
                fetch_value(hash, :metadata) || {}
            )
          end

          def fetch_value(hash, key)
            hash[key] || hash[key.to_s]
          end

          def sort_key(fact)
            [
              TYPE_ORDER.fetch(fact.type, 99),
              canonical_path(fact.path),
              canonical_value(fact.old_value),
              canonical_value(fact.new_value),
              canonical_value(fact.metadata)
            ]
          end

          def canonical_path(path)
            Array(path)
              .map(&:to_s)
              .join("\u0000")
          end

          def canonical_value(value)
            case value
            when Hash
              value
                .sort_by { |key, _| key.to_s }
                .map do |key, child|
                "#{key}=#{canonical_value(child)}"
              end
                .join("\u0001")

            when Array
              value
                .map { |child| canonical_value(child) }
                .join("\u0002")

            else
              value.to_s
            end
          end
        end
      end
    end
  end
end