# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class ResearchWorkspaceSnapshotService
            EVENT_TYPES = %w[
manual
save
resume
complete
archive
reopen
restore
].freeze

        def self.create!(workspace:, name:, reason: "manual", description: nil)
          new(
            workspace: workspace,
            name: name,
            reason: reason,
            description: description
          ).create!
        end

        def initialize(workspace:, name:, reason:, description:)
          @workspace = workspace
          @name = name
          @reason = normalize_event_type(reason)
          @description = description
        end

        def create!
          workspace.snapshots.create!(
            sequence: workspace.next_snapshot_sequence,
            event_type: reason,
            title: name,
            payload: build_payload,
            metadata: build_metadata
          )
        end

        private

        attr_reader :workspace, :name, :reason, :description

        def normalize_event_type(value)
          event_type = value.to_s

          event_type = "complete" if event_type == "completion"

          unless EVENT_TYPES.include?(event_type)
            raise ArgumentError,
                  "Unsupported snapshot event type: #{event_type.inspect}"
          end

          event_type
        end

        def build_payload
          {
            "workspace" => {
              "id" => workspace.id,
              "title" => workspace.title,
              "slug" => workspace.slug,
              "status" => workspace.status,
              "metadata" => workspace.metadata || {}
            },
            "items" => workspace.items.includes(
              :annotations,
              :evidences
            ).map do |item|
              {
                "id" => item.id,
                "kind" => item.kind,
                "title" => item.title,
                "description" => item.try(:description),
                "status" => item.status,
                "position" => item.position,
                "target_type" => item.try(:target_type),
                "target_id" => item.try(:target_id),
                "metadata" => item.try(:metadata) || {},
                "annotations" => item.annotations.map do |annotation|
                  serialize_record(
                    annotation,
                    %w[
                      id kind title body confidence status position
                      author_name reviewer_name reviewed_at
                    ]
                  )
                end,
                "evidences" => item.evidences.map do |evidence|
                  serialize_record(
                    evidence,
                    %w[
                      id title evidence_type source_url publisher author
                      published_on accessed_on excerpt notes confidence
                      verified verified_at research_workspace_annotation_id
                    ]
                  )
                end
              }
            end
          }
        end

        def serialize_record(record, allowed_attributes)
          record.attributes.slice(*allowed_attributes).transform_values do |value|
            value.respond_to?(:iso8601) ? value.iso8601 : value
          end
        end

        def build_metadata
          {
            "generated_at" => Time.current.iso8601,
            "generator" => self.class.name,
            "version" => 1,
            "description" => description,
            "summary" => {
              "item_count" => workspace.items.size,
              "annotation_count" => workspace.items.sum do |item|
                item.annotations.size
              end,
              "evidence_count" => workspace.items.sum do |item|
                item.evidences.size
              end
            }
          }
        end
      end
    end
  end
end

          end
        end
