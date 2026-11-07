# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class EvidenceCoverage
            def initialize(collection)
              @collection = collection
            end

            def call
              workspace_intelligence = WorkspaceIntelligence.new(collection).call

              {
                evidence_references: evidence_reference_count,
                discovered_evidence_records: workspace_intelligence[:evidence_count],
                workspaces: workspace_intelligence[:workspace_count],
                covered_workspaces: covered_workspaces(workspace_intelligence),
                coverage_percentage: workspace_intelligence[:coverage_percentage],
                coverage_source: "discovered_workspace_associations",
                evidence_by_workspace: workspace_intelligence[:evidence_by_workspace]
              }
            end

            private

            attr_reader :collection

            def evidence_reference_count
              return 0 unless collection.respond_to?(:evidence_references)

              collection.evidence_references.count
            rescue ActiveRecord::StatementInvalid
              0
            end

            def covered_workspaces(intelligence)
              intelligence[:evidence_by_workspace].count do |workspace|
                workspace[:evidence_count].positive?
              end
            end
          end
        end
      end
    end
  end
end