module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class Comparator
            def initialize(left, right)
              @left = left
              @right = right
            end

            def call
              {
                left: collection_summary(left),
                right: collection_summary(right),

                questions: compare_questions,
                objectives: compare_objectives,
                milestones: compare_milestones,
                findings: compare_findings,
                evidence: compare_evidence,
                relationships: compare_relationships
              }
            end

            private

            attr_reader :left, :right

            def collection_summary(collection)
              {
                id: collection.id,
                name: collection.try(:name),
                status: collection.try(:status)
              }
            end

            def compare_questions
              counts(
                left.questions.count,
                right.questions.count
              )
            end

            def compare_objectives
              counts(
                left.objectives.count,
                right.objectives.count
              )
            end

            def compare_milestones
              counts(
                left.milestones.count,
                right.milestones.count
              )
            end

            def compare_findings
              counts(
                left.findings.active.count,
                right.findings.active.count
              )
            end

            def compare_evidence
              counts(
                EvidenceInventory.new(left).call[:total_evidence],
                EvidenceInventory.new(right).call[:total_evidence]
              )
            end

            def compare_relationships
              counts(
                left.relationships.active.count,
                right.relationships.active.count
              )
            end

            def counts(left_value, right_value)
              {
                left: left_value,
                right: right_value,
                delta: right_value - left_value
              }
            end
          end
        end
      end
    end
  end
end
