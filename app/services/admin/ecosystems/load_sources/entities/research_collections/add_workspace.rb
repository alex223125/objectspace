module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class AddWorkspace
            def initialize(collection, workspace, notes: nil)
              @collection = collection
              @workspace = workspace
              @notes = notes
            end

            def call
              existing = @collection.memberships.find_by(
                research_workspace_id: @workspace.id
              )

              return existing if existing

              @collection.memberships.create!(
                research_workspace: @workspace,
                position: @collection.next_membership_position,
                notes: @notes
              )
            end
          end
        end
      end
    end
  end
end
