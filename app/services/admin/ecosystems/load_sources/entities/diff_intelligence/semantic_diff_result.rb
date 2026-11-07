# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticDiffResult
          attr_reader :facts

          def initialize(facts: [])
            @facts =
              Array(facts).map do |fact|
                normalize_fact(fact)
              end.freeze
          end

          def empty?
            facts.empty?
          end

          def changed
            facts.select { |fact| fact_status(fact) == "changed" }
          end

          def moved
            facts.select { |fact| fact_status(fact) == "moved" }
          end

          def added
            facts.select { |fact| fact_status(fact) == "added" }
          end

          def removed
            facts.select { |fact| fact_status(fact) == "removed" }
          end

          def identity_warnings
            facts.select do |fact|
              fact_status(fact) == "identity_warning"
            end
          end

          private

          def normalize_fact(fact)
            return fact if fact.is_a?(SemanticFact)

            hash =
              fact.respond_to?(:to_h) ? fact.to_h : {}

            hash = hash.transform_keys(&:to_sym)

            status =
              hash[:status] ||
                hash[:type]

            type =
              case status.to_s
              when "changed"
                :content_change
              when "moved"
                :semantic_movement
              when "added"
                :added_entity
              when "removed"
                :removed_entity
              when "identity_warning"
                :identity_warning
              else
                status.to_sym
              end

            SemanticFact.new(
              type: type,
              path: normalize_path(hash[:path]),
              identity: hash[:identity],
              old_index: hash[:old_index],
              new_index: hash[:new_index],
              old_value: hash[:old_value],
              new_value: hash[:new_value],
              metadata: hash[:metadata] || {}
            )
          end

          def normalize_path(path)
            return [] if path.nil?

            case path
            when Array
              path
            else
              path.to_s.split(".").reject(&:empty?)
            end
          end

          def fact_status(fact)
            if fact.respond_to?(:status)
              fact.status.to_s
            elsif fact.respond_to?(:type)
              fact.type.to_s
            end
          end
        end
      end
    end
  end
end