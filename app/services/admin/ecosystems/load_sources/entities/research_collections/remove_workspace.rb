module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class RemoveWorkspace
            def initialize(collection, workspace)
              @collection = collection
              @workspace = workspace
            end

            def call
              membership = @collection.memberships.find_by!(
                research_workspace_id: @workspace.id
              )

              membership.destroy!

              reorder_memberships

              true
            end

            private

            def reorder_memberships
              @collection.memberships
                         .order(:position, :created_at)
                         .each_with_index do |membership, index|
                next if membership.position == index

                membership.update_column(
                  :position,
                  index
                )
              end
            end
          end
        end
      end
    end
  end
end
