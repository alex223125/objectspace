# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ArraySemanticFacts
          Result =
            Struct.new(
              :facts,
              keyword_init: true
            ) do
              def moved
                facts.select(&:semantic_movement?)
              end

              def added
                facts.select(&:added_entity?)
              end

              def removed
                facts.select(&:removed_entity?)
              end

              def changed
                facts.select(&:content_change?)
              end

              def identity_warnings
                facts.select(&:identity_warning?)
              end

              def any?
                return facts.any? unless block_given?

                facts.any? { |fact| yield fact }
              end
            end

          def self.call(classification:)
            new(
              classification: classification
            ).call
          end

          def initialize(classification:)
            @classification = classification
          end

          def call
            facts = []

            @classification.matches.each do |match|
              path =
                path_for(match)

              if match.classification == :moved
                facts << SemanticFact.new(
                  type: :semantic_movement,
                  path: path,
                  identity: match.identity,
                  old_index: match.old_index,
                  new_index: match.new_index,
                  metadata: {
                    position_changed: true
                  }
                )
              elsif match.classification == :added
                facts << SemanticFact.new(
                  type: :added_entity,
                  path: path,
                  identity: match.identity,
                  new_index: match.new_index
                )
              elsif match.classification == :removed
                facts << SemanticFact.new(
                  type: :removed_entity,
                  path: path,
                  identity: match.identity,
                  old_index: match.old_index
                )
              end
            end

            @classification.warnings.each do |warning|
              facts << SemanticFact.new(
                type: :identity_warning,
                path: warning_path(warning),
                identity: warning.identity,
                metadata: {
                  warning_code: warning.code.to_s,
                  side: warning.side,
                  indexes: warning.indexes,
                  reason: warning.reason,
                  identity_issue:
                    warning.code == :missing_identity ?
                      "missing_identity" :
                      warning.code.to_s
                }
              )
            end

            Result.new(
              facts: facts.sort_by do |fact|
                [
                  fact.path.join("."),
                  fact.type.to_s,
                  fact.identity.to_s,
                  fact.old_index || Float::INFINITY,
                  fact.new_index || Float::INFINITY
                ]
              end
            )
          end

          private

          def path_for(match)
            base =
              @classification.respond_to?(:path) ?
                @classification.path :
                nil

            base =
              base.to_s unless base.nil?

            return [] if base.nil? || base.empty?

            base.split(".") +
              [match.identity.to_s]
          end

          def warning_path(warning)
            base =
              @classification.respond_to?(:path) ?
                @classification.path.to_s :
                ""

            parts =
              base.empty? ? [] : base.split(".")

            parts << warning.identity.to_s if warning.identity

            parts
          end
        end
      end
    end
  end
end