module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class PortfolioHealth
            def initialize(collection)
              @collection = collection
            end

            def call
              questions = question_score
              objectives = objective_score
              milestones = milestone_score
              evidence = evidence_score

              scores = [
                questions,
                objectives,
                milestones,
                evidence
              ]

              {
                score: scores.sum / scores.length,
                questions: questions,
                objectives: objectives,
                milestones: milestones,
                evidence: evidence
              }
            end

            private

            attr_reader :collection

            def question_score
              collection.question_resolution_percentage
            end

            def objective_score
              collection.objective_progress
            end

            def milestone_score
              collection.milestone_progress
            end

            def evidence_score
              inventory = EvidenceInventory.new(collection).call

              total_workspaces = inventory[:total_workspaces].to_i
              return 0 if total_workspaces.zero?

              workspaces_with_evidence =
                inventory[:workspaces_with_evidence].to_i

              (
                workspaces_with_evidence.to_f / total_workspaces * 100
              ).round
            end

          end
        end
      end
    end
  end
end
