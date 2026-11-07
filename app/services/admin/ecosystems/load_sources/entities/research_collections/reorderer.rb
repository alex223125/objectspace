module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class Reorderer
            def initialize(collection, membership_ids)
              @collection = collection
              @membership_ids = Array(membership_ids).map(&:to_i)
            end

            def call
              @membership_ids.each_with_index do |membership_id, index|
                @collection.memberships
                           .where(id: membership_id)
                           .update_all(
                             position: index,
                             updated_at: Time.current
                           )
              end

              @collection.memberships.reload
            end
          end
        end
      end
    end
  end
end
