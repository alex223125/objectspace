module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class CollectionBuilder
            def initialize(
              title:,
              description: nil,
              color: "orange",
              status: "active"
            )
              @title = title
              @description = description
              @color = color
              @status = status
            end

            def call
              ResearchCollection.create!(
                title: @title,
                description: @description,
                color: @color,
                status: @status
              )
            end
          end
        end
      end
    end
  end
end