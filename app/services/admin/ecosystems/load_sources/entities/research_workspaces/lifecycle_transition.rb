
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class LifecycleTransition
            class InvalidTransition < StandardError; end

            TRANSITIONS = {
              "complete" => {
                allowed_from: %w[active],
                method: :complete!
              },
              "archive" => {
                allowed_from: %w[active completed],
                method: :archive!
              },
              "reopen" => {
                allowed_from: %w[completed archived],
                method: :reopen!
              },
              "resume" => {
                allowed_from: %w[active],
                method: :resume!
              }
            }.freeze

            def initialize(workspace)
              @workspace = workspace
            end

            def call!(event)
              transition = TRANSITIONS[event.to_s]

              raise InvalidTransition,
                    "Unsupported lifecycle operation" unless transition

              workspace.with_lock do
                workspace.reload

                current_status = workspace.status.to_s

                unless transition[:allowed_from].include?(current_status)
                  raise InvalidTransition,
                        "Cannot #{event} workspace in #{current_status.inspect} status"
                end

                method = transition.fetch(:method)

                unless workspace.respond_to?(method)
                  raise InvalidTransition,
                        "Workspace does not implement #{method}"
                end

                workspace.public_send(method)
              end

              workspace.reload
            end

            private

            attr_reader :workspace
          end
        end
      end
    end
  end
end