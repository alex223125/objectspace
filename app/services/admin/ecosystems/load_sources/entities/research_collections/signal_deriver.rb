module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class SignalDeriver
            def initialize(collection)
              @collection = collection
            end

            def call
              adapter = WorkspaceAdapter.new(collection)

              adapter.workspaces.flat_map.with_index do |workspace, index|
                derive_for(workspace, index, adapter)
              end
            end

            private

            attr_reader :collection

            def derive_for(workspace, index, adapter)
              signals = []

              name = adapter.workspace_name(workspace)
              status = adapter.workspace_status(workspace)

              if status.present?
                signals << signal(
                  workspace,
                  "workspace_status",
                  "Workspace status",
                  "#{name} is currently #{status}.",
                  status_confidence(status),
                  index
                )
              end

              evidence = evidence_count(workspace)

              if evidence.zero?
                signals << signal(
                  workspace,
                  "gap",
                  "Evidence gap",
                  "#{name} currently has no detected evidence records.",
                  "medium",
                  index
                )
              else
                signals << signal(
                  workspace,
                  "evidence",
                  "Evidence available",
                  "#{name} has #{evidence} detected evidence records.",
                  "high",
                  index
                )
              end

              if workspace.respond_to?(:updated_at)
                signals << signal(
                  workspace,
                  "activity",
                  "Workspace activity",
                  "#{name} was last updated #{workspace.updated_at}.",
                  "medium",
                  index
                )
              end

              signals
            end

            def signal(workspace, type, title, statement, confidence, position)
              {
                research_workspace: workspace,
                signal_type: type,
                title: title,
                statement: statement,
                confidence: confidence,
                position: position
              }
            end

            def evidence_count(workspace)
              %i[
        evidence_references
        evidence
        evidence_items
        sources
        documents
        references
      ].each do |association|
                next unless workspace.respond_to?(association)

                return workspace.public_send(association).count
              end

              0
            rescue StandardError
              0
            end

            def status_confidence(status)
              %w[
        completed
        complete
        archived
      ].include?(status.to_s) ? "high" : "medium"
            end
          end
        end
      end
    end
  end
end
