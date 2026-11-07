module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class IntelligenceDashboard
            def initialize(collection)
              @collection = collection
            end

            def call
              {
                collection: collection,
                questions: questions,
                objectives: objectives,
                findings: findings,
                contradictions: contradictions,
                milestones: milestones,
                synthesis_notes: synthesis_notes,
                coverage: evidence_coverage,
                progress: progress
              }
            end

            private

            attr_reader :collection

            def questions
              collection.questions.ordered
            end

            def objectives
              collection.objectives.ordered
            end

            def findings
              collection.findings
                        .includes(:research_collection_memberships)
                        .ordered
            end

            def contradictions
              collection.findings
                        .contradictions
                        .ordered
            end

            def milestones
              collection.milestones.ordered
            end

            def synthesis_notes
              collection.synthesis_notes.ordered
            end

            def evidence_coverage
              ResearchCollections::EvidenceCoverage
                .new(collection)
                .call
            end

            def progress
              ResearchCollections::ProgressCalculator
                .new(collection)
                .call
            end
          end
        end
      end
    end
  end
end
