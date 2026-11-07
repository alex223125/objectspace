# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class ApplicationDiffBuilder
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
          return empty_diff unless comparable_versions?

          result =
            EntityVersionDiff.call(
              old_version: old_version,
              new_version: new_version,
              configuration: configuration
            )

          facts =
            extract_semantic_facts(result)

          ApplicationDiff.call(
            facts: facts
          )
        end

        private

        attr_reader(
          :old_version,
          :new_version,
          :configuration
        )

        def comparable_versions?
          old_version.present? &&
            new_version.present?
        end

        def extract_semantic_facts(result)
          if result.respond_to?(:semantic_facts)
            return result.semantic_facts
          end

          if result.respond_to?(:facts)
            return result.facts
          end

          if result.respond_to?(:to_h)
            hash = result.to_h

            if hash.key?(:semantic_facts)
              return hash[:semantic_facts]
            end

            if hash.key?("semantic_facts")
              return hash["semantic_facts"]
            end

            if hash.key?(:facts)
              return hash[:facts]
            end

            if hash.key?("facts")
              return hash["facts"]
            end
          end

          []
        end

        def empty_diff
          ApplicationDiff.call(
            facts: []
          )
        end
      end
    end
  end
end