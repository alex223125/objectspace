
require "digest"
require "json"


module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class SnapshotBuilder
            def initialize(collection:, label:, description: nil, created_by: nil)
              @collection = collection
              @label = label
              @description = description
              @created_by = created_by
            end

            def call
              ResearchCollectionSnapshot.transaction do
                sequence = collection.snapshots.maximum(:sequence).to_i + 1
                captured_at = Time.current

                payload = build_payload
                checksum = Digest::SHA256.hexdigest(
                  JSON.generate(canonical_payload(payload))
                )

                collection.snapshots.create!(
                  sequence: sequence,
                  label: label,
                  description: description,
                  payload: payload,
                  checksum: checksum,
                  captured_at: captured_at,
                  created_by: created_by
                )
              end
            end

            private

            attr_reader :collection, :label, :description, :created_by

            def build_payload
              {
                "schema_version" => 1,
                "collection" => {
                  "id" => collection.id,
                  "name" => collection.try(:name),
                  "status" => collection.try(:status),
                  "objective" => collection.try(:objective),
                  "research_question" => collection.try(:research_question),
                  "priority" => collection.try(:priority)
                },
                "intelligence" => ResearchCollections::IntelligenceBuilder
                                    .new(collection).call.deep_stringify_keys,
                "workspace_intelligence" => ResearchCollections::WorkspaceIntelligence
                                              .new(collection).call.deep_stringify_keys,
                "questions" => collection.questions.ordered.map do |item|
                  item.attributes.slice(
                    "id", "question", "context", "status",
                    "position", "resolved_at", "updated_at"
                  )
                end,
                "objectives" => collection.objectives.ordered.map do |item|
                  item.attributes.slice(
                    "id", "title", "description", "status",
                    "position", "progress", "updated_at"
                  )
                end,
                "milestones" => collection.milestones.ordered.map do |item|
                  item.attributes.slice(
                    "id", "title", "description", "status",
                    "target_date", "completed_at", "position", "updated_at"
                  )
                end,
                "findings" => collection.findings.ordered.map do |item|
                  item.attributes.slice(
                    "id", "title", "statement", "confidence",
                    "status", "position", "updated_at"
                  )
                end,
                "synthesis_notes" => collection.synthesis_notes.ordered.map do |item|
                  item.attributes.slice(
                    "id", "title", "content", "note_type",
                    "position", "updated_at"
                  )
                end,
                "relationships" => collection.investigation_relationships.ordered.map do |item|
                  item.attributes.slice(
                    "id", "source_workspace_id", "target_workspace_id",
                    "relationship_type", "status", "label",
                    "description", "confidence", "updated_at"
                  )
                end
              }
            end

            def canonical_payload(value)
              case value
              when Hash
                value.keys.sort.each_with_object({}) do |key, result|
                  result[key] = canonical_payload(value[key])
                end
              when Array
                value.map { |item| canonical_payload(item) }
              else
                value
              end
            end
          end
        end
      end
    end
  end
end
