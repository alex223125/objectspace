# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class SnapshotGuard
            def initialize(workspace, snapshot)
              @workspace = workspace
              @snapshot = snapshot
            end

            def validate!
              reflection = @workspace.class.reflect_on_association(
                :research_workspace_snapshots
              )

              unless reflection
                raise ActiveRecord::RecordNotFound,
                      "Workspace snapshot association is unavailable"
              end

              snapshot_exists = @workspace
                                  .research_workspace_snapshots
                                  .where(id: @snapshot.id)
                                  .exists?

              unless snapshot_exists
                raise ActiveRecord::RecordNotFound,
                      "Snapshot does not belong to this workspace"
              end

              true
            end
          end
        end
      end
    end
  end
end