# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class EntityVersionSemanticDiff
        Result = Struct.new(
          :old_version,
          :new_version,
          :semantic_result,
          :semantic_facts,
          :application_facts,
          :diff,
          :comparison_insight,
          keyword_init: true
        ) do
          def empty?
            diff.nil? || diff.respond_to?(:empty?) && diff.empty?
          end

          def to_h
            {
              old_version: old_version,
              new_version: new_version,
              semantic_facts: application_facts.to_a,
              diff: diff.respond_to?(:to_h) ? diff.to_h : diff,
              comparison_insight:
                comparison_insight.respond_to?(:to_h) ?
                  comparison_insight.to_h :
                  comparison_insight
            }
          end
        end

        def self.call(
          old_version:,
          new_version:,
          configuration: nil
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
          configuration: nil
        )
          @old_version = old_version
          @new_version = new_version
          @configuration =
            configuration ||
              default_configuration
        end

        def call
          validate_versions!

          semantic_result =
            build_semantic_result

          semantic_facts =
            normalize_semantic_facts(
              semantic_result
            )

          application_facts =
            build_application_facts(
              semantic_facts
            )

          application_diff =
            build_application_diff(
              application_facts
            )

          comparison_insight =
            build_comparison_insight(
              semantic_result
            )

          Result.new(
            old_version: old_version,
            new_version: new_version,
            semantic_result: semantic_result,
            semantic_facts: semantic_facts,
            application_facts: application_facts,
            diff: application_diff,
            comparison_insight: comparison_insight
          )
        end

        private

        attr_reader(
          :old_version,
          :new_version,
          :configuration
        )

        def validate_versions!
          if old_version.nil?
            raise ArgumentError,
                  "old_version is required"
          end

          if new_version.nil?
            raise ArgumentError,
                  "new_version is required"
          end

          if old_version.id.to_s == new_version.id.to_s
            raise ArgumentError,
                  "old_version and new_version must be different"
          end
        end

        def build_semantic_result
          ::Ecosystems::LoadSources::Entity::EntityVersionDiff.call(
            old_version: old_version,
            new_version: new_version,
            configuration: configuration
          )
        end

        def normalize_semantic_facts(result)
          contract =
            ::Ecosystems::LoadSources::Entity::DiffIntelligence::SemanticFactsContract
              .call(
                extract_facts(result)
              )

          contract.to_a
        end

        def build_application_facts(facts)
          ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationSemanticFacts
            .new(
              facts
            )
        end

        def build_application_diff(application_facts)
          ::Ecosystems::LoadSources::Entity::ApplicationDiff.call(
            facts: application_facts
          )
        end

        def build_comparison_insight(result)
          return nil unless comparison_insight_available?

          ::Ecosystems::LoadSources::Entity::DiffIntelligence::BuildComparisonInsight
            .call(
              result: result
            )
        end

        def comparison_insight_available?
          defined?(
            ::Ecosystems::LoadSources::Entity::DiffIntelligence::BuildComparisonInsight
          )
        end

        def extract_facts(result)
          if result.respond_to?(:semantic_facts)
            return result.semantic_facts
          end

          if result.respond_to?(:facts)
            return result.facts
          end

          if result.respond_to?(:to_h)
            hash =
              result.to_h

            if hash.respond_to?(:key?)
              return hash[:semantic_facts] if hash.key?(:semantic_facts)

              return hash["semantic_facts"] if hash.key?("semantic_facts")

              return hash[:facts] if hash.key?(:facts)

              return hash["facts"] if hash.key?("facts")
            end
          end

          []
        end

        def default_configuration
          ::Ecosystems::LoadSources::Entity::DiffIntelligence::Configuration.empty
        end
      end
    end
  end
end