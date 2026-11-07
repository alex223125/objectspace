module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class WorkspaceAdapter
            def initialize(collection)
              @collection = collection
            end

            def workspaces
              return [] unless collection.respond_to?(:memberships)

              collection.memberships.filter_map do |membership|
                workspace_from(membership)
              end
            end

            def workspace_name(workspace)
              return workspace.name if workspace.respond_to?(:name)
              return workspace.title if workspace.respond_to?(:title)

              "Workspace ##{workspace.id}"
            end

            def workspace_status(workspace)
              return workspace.status if workspace.respond_to?(:status)

              nil
            end

            def workspace_identifier(workspace)
              workspace.id
            end

            private

            attr_reader :collection

            def workspace_from(membership)
              if membership.respond_to?(:research_workspace)
                membership.research_workspace
              elsif membership.respond_to?(:workspace)
                membership.workspace
              elsif membership.respond_to?(:research_workspace_id)
                ResearchWorkspace.find_by(
                  id: membership.research_workspace_id
                )
              end
            end
          end
        end
      end
    end
  end
end