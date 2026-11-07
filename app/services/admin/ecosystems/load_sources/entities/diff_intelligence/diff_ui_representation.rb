# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class DiffUIRepresentation
          TYPE_ORDER = {
            identity_warning: 0,
            removed_entity: 1,
            semantic_movement: 2,
            content_change: 3,
            added_entity: 4
          }.freeze

          attr_reader :facts

          def self.call(source)
            new(source).call
          end

          def initialize(source)
            @source = source
          end

          def call
            @facts =
              build_facts
                .sort_by { |fact| sort_key(fact) }

            self
          end

          def empty?
            facts.empty?
          end

          def size
            facts.size
          end

          def content_changes
            facts.select(&:content_change?)
          end

          def movements
            facts.select(&:semantic_movement?)
          end

          def additions
            facts.select(&:added_entity?)
          end

          def removals
            facts.select(&:removed_entity?)
          end

          def warnings
            facts.select(&:identity_warning?)
          end

          def counts
            {
              content_change: content_changes.size,
              semantic_movement: movements.size,
              added_entity: additions.size,
              removed_entity: removals.size,
              identity_warning: warnings.size
            }
          end

          def to_h
            {
              facts: facts.map(&:to_h),
              counts: counts
            }
          end

          def as_json(*)
            to_h
          end

          private

          attr_reader :source

          def build_facts
            application_facts.map do |fact|
              DiffUIFact.new(
                type: fact.type,
                path: fact.path,
                identity: fact.identity,
                old_index: fact.old_index,
                new_index: fact.new_index,
                old_value: fact.old_value,
                new_value: fact.new_value,
                metadata: fact.metadata
              )
            end
          end

          def application_facts
            if source.is_a?(ApplicationSemanticFacts)
              source.facts
            elsif source.respond_to?(:facts)
              source.facts
            else
              ApplicationSemanticFacts
                .call(source)
                .facts
            end
          end

          def sort_key(fact)
            [
              fact.path_string,
              TYPE_ORDER.fetch(fact.type, 99),
              fact.identity.to_s,
              fact.old_index || -1,
              fact.new_index || -1,
              fact.old_value.to_s,
              fact.new_value.to_s
            ]
          end
        end
      end
    end
  end
end