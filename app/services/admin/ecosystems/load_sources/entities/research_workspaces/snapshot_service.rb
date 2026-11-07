
# frozen_string_literal: true

require "digest"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class SnapshotService
            EXCLUDED_ATTRIBUTES = %w[
              id
              created_at
              updated_at
              research_workspace_id
              research_workspace_item_id
            ].freeze

            def initialize(workspace)
              @workspace = workspace
            end

            def create!(label: nil, kind: "manual")
              payload = build_payload
              json = JSON.generate(payload)

              @workspace.research_workspace_snapshots.create!(
                kind: kind,
                label: label.presence || default_label,
                data: payload,
                checksum: Digest::SHA256.hexdigest(json)
              )
            end

            private

            attr_reader :workspace

            def build_payload
              {
                "version" => 1,
                "workspace" => workspace_attributes,
                "items" => items_payload,
                "captured_at" => Time.current.iso8601
              }
            end

            def workspace_attributes
              attributes_for(
                workspace,
                excluded: %w[id created_at updated_at]
              )
            end

            def items_payload
              workspace.items
                       .order(:position, :created_at)
                       .map do |item|
                {
                  "source_id" => item.id,
                  "attributes" => attributes_for(
                    item,
                    excluded: EXCLUDED_ATTRIBUTES
                  ),
                  "annotations" => item.annotations.ordered.map do |annotation|
                    {
                      "source_id" => annotation.id,
                      "attributes" => attributes_for(
                        annotation,
                        excluded: EXCLUDED_ATTRIBUTES
                      )
                    }
                  end,
                  "evidences" => item.evidences.recent.map do |evidence|
                    {
                      "source_id" => evidence.id,
                      "source_annotation_id" =>
                        evidence.research_annotation_id,
                      "attributes" => attributes_for(
                        evidence,
                        excluded: EXCLUDED_ATTRIBUTES
                      )
                    }
                  end
                }
              end
            end

            def attributes_for(record, excluded:)
              record.attributes.except(*excluded)
            end

            def default_label
              "Snapshot #{Time.current.strftime('%Y-%m-%d %H:%M')}"
            end
          end
        end
      end
    end
  end
end