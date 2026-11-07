module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class IntelligenceBuilder
            def initialize(collection)
              @collection = collection
            end

            def call
              {
                collection: collection_summary,
                questions: questions_summary,
                objectives: objectives_summary,
                milestones: milestones_summary,
                findings: findings_summary,
                synthesis: synthesis_summary,
                evidence: evidence_summary,
                contradictions: contradictions_summary
              }
            end

            private

            attr_reader :collection

            def collection_summary
              {
                id: collection.id,
                name: collection.try(:name),
                status: collection.try(:status),
                objective: collection.try(:objective),
                research_question: collection.try(:research_question)
              }
            end

            def questions_summary
              total = collection.questions.count
              resolved = collection.questions.resolved_questions.count

              {
                total: total,
                open: collection.questions.open_questions.count,
                resolved: resolved,
                resolution_percentage: percentage(resolved, total)
              }
            end

            def objectives_summary
              records = collection.objectives.to_a

              {
                total: records.length,
                active: records.count { |item| item.status == "active" },
                completed: records.count { |item| item.status == "completed" },
                progress: average(records.map(&:progress))
              }
            end

            def milestones_summary
              records = collection.milestones.to_a

              {
                total: records.length,
                completed: records.count { |item| item.status == "completed" },
                pending: records.count { |item| item.status == "pending" },
                progress: percentage(
                  records.count { |item| item.status == "completed" },
                  records.length
                )
              }
            end

            def findings_summary
              records = collection.findings.active.to_a

              {
                total: records.length,
                high_confidence: records.count { |item| item.confidence == "high" },
                medium_confidence: records.count { |item| item.confidence == "medium" },
                low_confidence: records.count { |item| item.confidence == "low" }
              }
            end

            def synthesis_summary
              records = collection.synthesis_notes.to_a

              {
                total: records.length,
                synthesis: records.count { |item| item.note_type == "synthesis" },
                observations: records.count { |item| item.note_type == "observation" },
                conclusions: records.count { |item| item.note_type == "conclusion" },
                contradictions: records.count { |item| item.note_type == "contradiction" }
              }
            end

            def evidence_summary
              if collection.respond_to?(:evidence_references)
                {
                  total: collection.evidence_references.count
                }
              else
                {
                  total: 0
                }
              end
            end

            def contradictions_summary
              contradictions = collection.synthesis_notes.contradictions

              {
                total: contradictions.count,
                unresolved: contradictions.count
              }
            end

            def percentage(numerator, denominator)
              return 0 if denominator.to_i.zero?

              ((numerator.to_f / denominator) * 100).round
            end

            def average(values)
              return 0 if values.empty?

              (values.sum.to_f / values.length).round
            end
          end
        end
      end
    end
  end
end