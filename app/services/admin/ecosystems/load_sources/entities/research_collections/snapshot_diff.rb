module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class SnapshotDiff
            def initialize(before:, after:)
              @before = before
              @after = after
            end

            def call
              before_payload = before.payload || {}
              after_payload = after.payload || {}

              {
                before: snapshot_metadata(before),
                after: snapshot_metadata(after),
                collection: compare_hash(
                  before_payload["collection"] || {},
                  after_payload["collection"] || {}
                ),
                metrics: compare_hash(
                  before_payload.dig("intelligence", "questions") || {},
                  after_payload.dig("intelligence", "questions") || {}
                ).merge(
                  objectives: compare_hash(
                    before_payload.dig("intelligence", "objectives") || {},
                    after_payload.dig("intelligence", "objectives") || {}
                  ),
                  milestones: compare_hash(
                    before_payload.dig("intelligence", "milestones") || {},
                    after_payload.dig("intelligence", "milestones") || {}
                  ),
                  findings: compare_hash(
                    before_payload.dig("intelligence", "findings") || {},
                    after_payload.dig("intelligence", "findings") || {}
                  )
                ),
                records: {
                  questions: compare_records(
                    before_payload["questions"], after_payload["questions"]
                  ),
                  objectives: compare_records(
                    before_payload["objectives"], after_payload["objectives"]
                  ),
                  milestones: compare_records(
                    before_payload["milestones"], after_payload["milestones"]
                  ),
                  findings: compare_records(
                    before_payload["findings"], after_payload["findings"]
                  ),
                  synthesis_notes: compare_records(
                    before_payload["synthesis_notes"],
                    after_payload["synthesis_notes"]
                  ),
                  relationships: compare_records(
                    before_payload["relationships"],
                    after_payload["relationships"]
                  )
                }
              }
            end

            private

            attr_reader :before, :after

            def snapshot_metadata(snapshot)
              {
                id: snapshot.id,
                sequence: snapshot.sequence,
                label: snapshot.label,
                captured_at: snapshot.captured_at
              }
            end

            def compare_hash(left, right)
              (left.keys | right.keys).sort.each_with_object({}) do |key, result|
                old_value = left[key]
                new_value = right[key]
                next if old_value == new_value

                result[key] = { before: old_value, after: new_value }
              end
            end

            def compare_records(left, right)
              left_by_id = Array(left).index_by { |item| item["id"].to_s }
              right_by_id = Array(right).index_by { |item| item["id"].to_s }

              {
                added: (right_by_id.keys - left_by_id.keys).filter_map do |id|
                  right_by_id[id]
                end,
                removed: (left_by_id.keys - right_by_id.keys).filter_map do |id|
                  left_by_id[id]
                end,
                changed: (left_by_id.keys & right_by_id.keys).filter_map do |id|
                  changes = compare_hash(left_by_id[id], right_by_id[id])
                  next if changes.empty?

                  {
                    id: id,
                    changes: changes
                  }
                end
              }
            end
          end
        end
      end
    end
  end
end
