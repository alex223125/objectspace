module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class Manager
            def initialize(collection)
              @collection = collection
            end

            def add_workspace(workspace, pinned: false, note: nil)
              membership = @collection.memberships.find_or_initialize_by(
                research_workspace: workspace
              )

              membership.position ||= next_position
              membership.pinned = pinned
              membership.note = note

              membership.save!

              membership
            end

            def remove_workspace(workspace)
              @collection.memberships
                         .where(research_workspace: workspace)
                         .destroy_all
            end

            def pin_workspace(workspace)
              membership_for(workspace)&.pin!
            end

            def unpin_workspace(workspace)
              membership_for(workspace)&.unpin!
            end

            private

            def membership_for(workspace)
              @collection.memberships.find_by(
                research_workspace: workspace
              )
            end

            def next_position
              (@collection.memberships.maximum(:position) || -1) + 1
            end
          end
        end
      end
    end
  end
end
