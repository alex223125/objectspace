
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class LifecycleOperation
            ACTIONS = %w[
              start
              pause
              resume
              complete
              reopen
              archive
            ].freeze

            def initialize(workspace:, action:)
              @workspace = workspace
              @action = action.to_s
            end

            def call!
              unless ACTIONS.include?(@action)
                raise ArgumentError,
                      "Unsupported lifecycle action: #{@action.inspect}"
              end

              @workspace.class.transaction do
                @workspace.lock!

                public_method = "#{@action}!"

                unless @workspace.respond_to?(public_method)
                  raise NoMethodError,
                        "Workspace does not implement #{public_method}"
                end

                @workspace.public_send(public_method)
                @workspace.reload
              end

              @workspace
            end

            private

            attr_reader :workspace, :action
          end
        end
      end
    end
  end
end