module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class InvestigationSummary
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              {
                items: workspace.items.count,
                entities: workspace.entity_count,
                questions: workspace.question_count,
                notes: workspace.note_count,
                completed_items: workspace.completed_items_count,
                open_items: workspace.open_items_count,
                progress: workspace.progress,
                annotations: workspace.annotation_count,
                evidence: workspace.evidence_count,
                verified_evidence: workspace.verified_evidence_count,
                evidence_coverage: workspace.evidence_coverage,
                research_strength: workspace.research_strength
              }
            end

            private

            attr_reader :workspace
          end
        end
      end
    end
  end
end