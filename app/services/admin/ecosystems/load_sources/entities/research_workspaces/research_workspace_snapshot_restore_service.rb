module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class ResearchWorkspaceSnapshotRestoreService
            def self.restore!(snapshot:)
              new(snapshot).restore!
            end

            def initialize(snapshot)
              @snapshot = snapshot
            end

            def restore!
              workspace = snapshot.research_workspace

              ResearchWorkspaceSnapshotService.create!(
                workspace: workspace,
                name: "Before restore from #{snapshot.name}",
                reason: "pre_restore",
                description: "Automatic safety snapshot created before restore."
              )

              workspace.update!(
                title: snapshot.state.dig("workspace", "title").presence || workspace.title,
                metadata: snapshot.state.dig("workspace", "metadata") || workspace.metadata
              )

              workspace.touch_last_opened!

              workspace
            end

            private

            attr_reader :snapshot
          end
        end
      end
    end
  end
end