
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class CollectionDashboard
            attr_reader :collection

            def initialize(collection)
              @collection = collection
            end

            def call
              {
                workspace_count: collection.workspace_count,
                pinned_workspace_count: collection.pinned_workspace_count,
                completed_workspace_count: collection.completed_workspace_count,
                progress_percentage: collection.progress_percentage,
                evidence_count: collection.evidence_references.count,
                tag_count: collection.tags.count,
                active_workspace_count: active_workspace_count,
                recent_workspaces: recent_workspaces,
                pinned_workspaces: pinned_workspaces
              }
            end

            private

            def active_workspace_count
              collection.research_workspaces.where(status: "active").count
            end

            def recent_workspaces
              collection.memberships
                        .includes(:research_workspace)
                        .order(updated_at: :desc)
                        .limit(5)
            end

            def pinned_workspaces
              collection.memberships
                        .includes(:research_workspace)
                        .where(pinned: true)
                        .order(position: :asc)
            end
          end
        end
      end
    end
  end
end