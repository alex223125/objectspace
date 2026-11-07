# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities
      class BuildApplicationEntityDiff
        Result = Struct.new(
          :diff,
          :comparison,
          :old_version,
          :new_version,
          keyword_init: true
        ) do
          def to_h
            {
              diff: diff.respond_to?(:to_h) ? diff.to_h : diff,
              comparison:
                comparison.respond_to?(:to_h) ? comparison.to_h : comparison,
              old_version: old_version,
              new_version: new_version
            }
          end

          def as_json(*)
            to_h
          end

          def facts
            return [] unless diff.respond_to?(:facts)

            diff.facts
          end

          def empty?
            diff.respond_to?(:empty?) ? diff.empty? : facts.empty?
          end
        end

        def self.call(
          old_version:,
          new_version:,
          configuration:
        )
          new(
            old_version: old_version,
            new_version: new_version,
            configuration: configuration
          ).call
        end

        def initialize(
          old_version:,
          new_version:,
          configuration:
        )
          @old_version = old_version
          @new_version = new_version
          @configuration = configuration
        end

        def call
          comparison =
            ::Ecosystems::LoadSources::Entity::EntityVersionDiff.call(
              old_version: old_version,
              new_version: new_version,
              configuration: configuration
            )

          semantic_facts =
            extract_semantic_facts(comparison)

          application_facts =
            ::Ecosystems::LoadSources::Entity::DiffIntelligence::SemanticFactsContract
              .call(semantic_facts)

          diff =
            ::Ecosystems::LoadSources::Entity::ApplicationDiff.call(
              facts: application_facts
            )

          Result.new(
            diff: diff,
            comparison: comparison,
            old_version: old_version,
            new_version: new_version
          )
        end

        private

        attr_reader(
          :old_version,
          :new_version,
          :configuration
        )

        def extract_semantic_facts(result)
          if result.respond_to?(:semantic_facts)
            return result.semantic_facts
          end

          if result.respond_to?(:facts)
            return result.facts
          end

          if result.respond_to?(:events)
            return result.events
          end

          if result.respond_to?(:to_h)
            hash =
              result.to_h

            return hash[:semantic_facts] if
              hash.key?(:semantic_facts)

            return hash["semantic_facts"] if
              hash.key?("semantic_facts")

            return hash[:facts] if
              hash.key?(:facts)

            return hash["facts"] if
              hash.key?("facts")

            return hash[:events] if
              hash.key?(:events)

            return hash["events"] if
              hash.key?("events")
          end

          []
        end
      end
    end
  end
end