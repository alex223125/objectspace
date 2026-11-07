
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class AddItem
            def initialize(workspace:, attributes:)
              @workspace = workspace
              @attributes = attributes
            end

            def call
              item = nil

              @workspace.class.transaction do
                @workspace.lock!

                position = @workspace.items.maximum(:position).to_i + 1

                item = @workspace.items.create!(
                  @attributes.merge(position: position)
                )
              end

              item
            end

            private

            attr_reader :workspace, :attributes
          end
        end
      end
    end
  end
end