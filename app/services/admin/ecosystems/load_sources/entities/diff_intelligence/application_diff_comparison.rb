# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationDiffComparison
          attr_reader :request, :semantic_result, :facts, :payload

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
            @request =
              ComparisonRequest.new(
                old_snapshot: old_snapshot,
                new_snapshot: new_snapshot,
                configuration: configuration
              )
          end

          def call
            @semantic_result =
              SemanticComparator
                .new(
                  configuration: request.configuration
                )
                .call(
                  request.old_snapshot,
                  request.new_snapshot
                )

            @facts =
              ApplicationSemanticFacts
                .call(semantic_result)

            @payload =
              DiffUIPayload
                .call(facts)

            self
          end

          def ui_payload
            payload
          end

          def ui_facts
            payload.facts
          end

          def counts
            payload.counts
          end

          def to_h
            payload.to_h
          end

          def as_json(*)
            to_h
          end

          def empty?
            payload.empty?
          end

          def size
            payload.facts.size
          end
        end
      end
    end
  end
end