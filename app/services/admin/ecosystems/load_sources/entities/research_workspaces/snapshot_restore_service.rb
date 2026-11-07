
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class SnapshotRestoreService
            WORKSPACE_FIELDS = %w[
              title
              slug
              summary
              metadata
            ].freeze

            def initialize(workspace, snapshot)
              @workspace = workspace
              @snapshot = snapshot
            end

            def call!
              validate_snapshot!

              workspace.class.transaction do
                restore_workspace
                workspace.items.destroy_all
                restore_items
              end

              workspace.reload
            end

            private

            attr_reader :workspace, :snapshot

            def validate_snapshot!
              unless snapshot.research_workspace_id == workspace.id
                raise ArgumentError,
                      "Snapshot does not belong to this workspace"
              end

              data = snapshot.data

              unless data.is_a?(Hash) &&
                data["items"].is_a?(Array) &&
                data["workspace"].is_a?(Hash)
                raise ArgumentError, "Snapshot data is invalid"
              end

              data.fetch("items").each do |item_payload|
                unless item_payload.is_a?(Hash) &&
                  item_payload["attributes"].is_a?(Hash)
                  raise ArgumentError, "Snapshot item data is invalid"
                end

                %w[annotations evidences].each do |key|
                  value = item_payload.fetch(key, [])
                  unless value.is_a?(Array) &&
                    value.all? { |entry| entry.is_a?(Hash) }
                    raise ArgumentError,
                          "Snapshot #{key} data is invalid"
                  end
                end
              end
            end

            def restore_workspace
              attributes =
                snapshot.data.fetch("workspace").slice(*WORKSPACE_FIELDS)

              # Never change the workspace's ownership or identity.
              workspace.update!(attributes)
            end

            def restore_items
              snapshot.data.fetch("items").each do |payload|
                item = workspace.items.create!(
                  clean_attributes(payload.fetch("attributes"))
                )

                annotation_map = restore_annotations(
                  item,
                  payload.fetch("annotations", [])
                )

                restore_evidences(
                  item,
                  payload.fetch("evidences", []),
                  annotation_map
                )
              end
            end

            def restore_annotations(item, entries)
              entries.each_with_object({}) do |entry, map|
                attributes = entry["attributes"] || entry
                old_id = entry["source_id"] || attributes["id"]

                annotation = item.annotations.create!(
                  clean_attributes(attributes).merge(
                    research_workspace: workspace
                  )
                )

                map[old_id.to_s] = annotation.id if old_id.present?
              end
            end

            def restore_evidences(item, entries, annotation_map)
              entries.each do |entry|
                attributes = entry["attributes"] || entry

                old_annotation_id =
                  entry["source_annotation_id"] ||
                    attributes["research_annotation_id"]

                cleaned = clean_attributes(attributes)

                if old_annotation_id.present?
                  cleaned["research_annotation_id"] =
                    annotation_map[old_annotation_id.to_s]
                end

                item.evidences.create!(
                  cleaned.merge(research_workspace: workspace)
                )
              end
            end

            def clean_attributes(attributes)
              attributes.except(
                "id",
                "created_at",
                "updated_at",
                "research_workspace_id",
                "research_workspace_item_id"
              )
            end
          end
        end
      end
    end
  end
end