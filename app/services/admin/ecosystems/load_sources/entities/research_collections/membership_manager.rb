module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class MembershipManager
            def initialize(collection)
              @collection = collection
            end

            def add!(workspace, pinned: false)
              existing = @collection.memberships.find_by(
                research_workspace: workspace
              )

              return existing if existing

              position = next_position

              @collection.memberships.create!(
                research_workspace: workspace,
                position: position,
                pinned: pinned,
                added_at: Time.current
              )
            end

            def remove!(workspace)
              @collection.memberships
                         .where(research_workspace: workspace)
                         .destroy_all
            end

            def pin!(workspace)
              membership_for(workspace).update!(
                pinned: true
              )
            end

            def unpin!(workspace)
              membership_for(workspace).update!(
                pinned: false
              )
            end

            private

            def membership_for(workspace)
              @collection.memberships.find_by!(
                research_workspace: workspace
              )
            end

            def next_position
              @collection.memberships.maximum(:position).to_i + 1
            end
          end
        end
      end
    end
  end
end
