# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class EvidenceInventory
            ASSOCIATION_CANDIDATES = %i[
      evidence_references
      evidence
      evidence_items
      sources
      documents
      references
    ].freeze

            def initialize(collection)
              @collection = collection
            end

            def call
              workspaces = WorkspaceAdapter
                             .new(collection)
                             .workspaces

              records = workspaces.map do |workspace|
                {
                  workspace_id: workspace.id,
                  workspace_name: workspace_name(workspace),
                  evidence_count: evidence_count(workspace),
                  last_activity: workspace.updated_at
                }
              end

              {
                total_workspaces: records.length,
                total_evidence: records.sum { |item| item[:evidence_count] },
                workspaces_with_evidence: records.count do |item|
                  item[:evidence_count] > 0
                end,
                records: records
              }
            end

            private

            attr_reader :collection

            def workspace_name(workspace)
              WorkspaceAdapter
                .new(collection)
                .workspace_name(workspace)
            end

            def evidence_count(workspace)
              ASSOCIATION_CANDIDATES.each do |association|
                next unless workspace.respond_to?(association)

                return workspace.public_send(association).count
              end

              0
            rescue StandardError
              0
            end
          end
        end
      end
    end
  end
end
