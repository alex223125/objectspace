module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          module ResearchWorkspaces
            class SaveInvestigation
              Result = Struct.new(
                :workspace,
                :created_item,
                keyword_init: true
              )

              def initialize(
                workspace:,
                title:,
                body: nil,
                kind: "note",
                target_type: nil,
                target_id: nil
              )
                @workspace = workspace
                @title = title
                @body = body
                @kind = kind
                @target_type = target_type
                @target_id = target_id
              end

              def call
                ActiveRecord::Base.transaction do
                  item = workspace.items.create!(
                    kind: normalized_kind,
                    title: title,
                    body: body,
                    target_type: target_type.presence,
                    target_id: normalized_target_id,
                    status: "open",
                    position: next_position
                  )

                  Result.new(
                    workspace: workspace,
                    created_item: item
                  )
                end
              end

              private

              attr_reader :workspace,
                          :title,
                          :body,
                          :kind,
                          :target_type,
                          :target_id

              def normalized_kind
                allowed = %w[
          entity
          relationship
          question
          note
          evidence
          milestone
          recommendation
        ]

                allowed.include?(kind.to_s) ? kind.to_s : "note"
              end

              def normalized_target_id
                value = target_id.to_i

                value.positive? ? value : nil
              end

              def next_position
                workspace.items.maximum(:position).to_i + 1
              end
            end
          end
        end
      end
    end
  end
end