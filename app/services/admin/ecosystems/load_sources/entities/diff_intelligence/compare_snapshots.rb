# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class CompareSnapshots
          Result = Struct.new(
            :facts,
            :warnings,
            :metadata,
            keyword_init: true
          )

          def self.call(
            old_snapshot:,
            new_snapshot:,
            configuration:
          )
            new(
              old_snapshot: old_snapshot,
              new_snapshot: new_snapshot,
              configuration: configuration
            ).call
          end

          def initialize(
            old_snapshot:,
            new_snapshot:,
            configuration:
          )
            @old_snapshot = old_snapshot
            @new_snapshot = new_snapshot
            @configuration = configuration
          end

          def call
            comparison =
              SemanticComparator
                .new(
                  configuration: configuration
                )
                .call(
                  old_snapshot,
                  new_snapshot
                )

            facts =
              ApplicationFacts
                .new(
                  result: comparison
                )
                .call

            warnings =
              facts.select do |fact|
                fact.type == :identity_warning
              end

            Result.new(
              facts: facts,
              warnings: warnings,
              metadata: {
                version: 1,
                deterministic: true
              }
            )
          end

          private

          attr_reader \
            :old_snapshot,
            :new_snapshot,
            :configuration
        end
      end
    end
  end
end