module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class SnapshotRestorer
            def initialize(snapshot)
              @snapshot = snapshot
              @workspace = snapshot.research_workspace
            end

            def call
              ActiveRecord::Base.transaction do
                destroy_current_research_records!
                restore_workspace_attributes!
                restore_items!
                restore_annotations!
                restore_evidences!
                create_restore_snapshot!
              end

              @workspace.reload
            end

            private

            def payload
              @snapshot.payload || {}
            end

            def workspace_attributes
              payload.fetch("workspace", {})
            end

            def items
              Array(payload["items"])
            end

            def annotations
              Array(payload["annotations"])
            end

            def evidences
              Array(payload["evidences"])
            end

            def destroy_current_research_records!
              @workspace.items.destroy_all
            end

            def restore_workspace_attributes!
              allowed = ResearchWorkspace.column_names

              attributes = workspace_attributes
                             .stringify_keys
                             .slice(*allowed)

              attributes.delete("id")
              attributes.delete("created_at")
              attributes.delete("updated_at")

              @workspace.update!(
                attributes.merge(
                  "status" => "active",
                  "last_resumed_at" => Time.current,
                  "saved_at" => @workspace.saved_at || Time.current
                )
              )
            end

            def restore_items!
              items.each do |item_attributes|
                attributes = permitted_attributes(
                  ResearchWorkspaceItem,
                  item_attributes,
                  excluded: %w[
            id
            created_at
            updated_at
            research_workspace_id
          ]
                )

                @workspace.items.create!(attributes)
              end
            end

            def restore_annotations!
              annotations.each do |annotation_attributes|
                attributes = permitted_attributes(
                  ResearchAnnotation,
                  annotation_attributes,
                  excluded: %w[
            id
            created_at
            updated_at
            research_workspace_id
            research_workspace_item_id
          ]
                )

                item = find_item_for_annotation(attributes)

                item.annotations.create!(
                  attributes.merge(
                    research_workspace: @workspace
                  )
                )
              end
            end

            def restore_evidences!
              evidences.each do |evidence_attributes|
                attributes = permitted_attributes(
                  ResearchEvidence,
                  evidence_attributes,
                  excluded: %w[
            id
            created_at
            updated_at
            research_workspace_id
            research_workspace_item_id
            research_annotation_id
          ]
                )

                item = find_item_for_evidence(attributes)

                item.evidences.create!(
                  attributes.merge(
                    research_workspace: @workspace
                  )
                )
              end
            end

            def find_item_for_annotation(attributes)
              find_item(attributes)
            end

            def find_item_for_evidence(attributes)
              find_item(attributes)
            end

            def find_item(attributes)
              kind = attributes["kind"]
              title = attributes["title"]
              target_type = attributes["target_type"]
              target_id = attributes["target_id"]

              scope = @workspace.items.where(
                kind: kind,
                title: title
              )

              scope = scope.where(
                target_type: target_type
              ) if target_type.present?

              scope = scope.where(
                target_id: target_id
              ) if target_id.present?

              scope.order(:position, :id).first ||
                raise(
                  ActiveRecord::RecordNotFound,
                  "Unable to map snapshot record back to a workspace item."
                )
            end

            def permitted_attributes(model, attributes, excluded:)
              model
                .column_names
                .then { |columns| attributes.stringify_keys.slice(*columns) }
                .except(*excluded)
            end

            def create_restore_snapshot!
              ResearchWorkspaces::SnapshotBuilder.new(
                @workspace,
                event_type: "restore",
                title: "Restored snapshot ##{@snapshot.sequence}",
                description: "Workspace restored from snapshot ##{@snapshot.sequence}"
              ).call
            end
          end
        end
      end
    end
  end
end