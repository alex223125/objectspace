module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class SnapshotBuilder
            def initialize(
              workspace,
              event_type: "manual",
              title: nil,
              description: nil,
              created_by_name: nil
            )
              @workspace = workspace
              @event_type = event_type.to_s
              @title = title
              @description = description
              @created_by_name = created_by_name
            end

            def call
              ResearchWorkspaceSnapshot.transaction do
                sequence = @workspace.next_snapshot_sequence

                snapshot = @workspace.snapshots.create!(
                  sequence: sequence,
                  event_type: @event_type,
                  title: @title.presence || default_title,
                  description: @description,
                  created_by_name: @created_by_name,
                  payload: build_payload,
                  metadata: build_metadata
                )

                @workspace.update!(
                  last_snapshot_at: snapshot.created_at,
                  saved_at: @workspace.saved_at || snapshot.created_at
                )

                snapshot
              end
            end

            private

            def default_title
              "#{@event_type.to_s.humanize} snapshot ##{@workspace.next_snapshot_sequence}"
            end

            def build_payload
              {
                "workspace" => workspace_payload,
                "items" => item_payload,
                "annotations" => annotation_payload,
                "evidences" => evidence_payload
              }
            end

            def workspace_payload
              attributes_for(
                @workspace,
                except: %w[
          id
          created_at
          updated_at
          owner_id
          owner_type
        ]
              )
            end

            def item_payload
              @workspace.items
                        .order(position: :asc, id: :asc)
                        .map do |item|
                attributes_for(
                  item,
                  except: %w[
              id
              created_at
              updated_at
              research_workspace_id
            ]
                )
              end
            end

            def annotation_payload
              @workspace.research_annotations
                        .order(position: :asc, id: :asc)
                        .map do |annotation|
                attributes_for(
                  annotation,
                  except: %w[
              id
              created_at
              updated_at
              research_workspace_id
              research_workspace_item_id
            ]
                )
              end
            end

            def evidence_payload
              @workspace.research_evidences
                        .order(id: :asc)
                        .map do |evidence|
                attributes_for(
                  evidence,
                  except: %w[
              id
              created_at
              updated_at
              research_workspace_id
              research_workspace_item_id
            ]
                )
              end
            end

            def attributes_for(record, except:)
              record
                .serializable_hash
                .except(*except)
            end

            def build_metadata
              {
                "summary" => {
                  "items" => @workspace.items.count,
                  "annotations" => @workspace.research_annotations.count,
                  "evidences" => @workspace.research_evidences.count,
                  "verified_evidences" => @workspace.verified_evidence_count,
                  "research_strength" => @workspace.research_strength,
                  "progress" => @workspace.progress
                },
                "generated_at" => Time.current.iso8601
              }
            end
          end
        end
      end
    end
  end
end
