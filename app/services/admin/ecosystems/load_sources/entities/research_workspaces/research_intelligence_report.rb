
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class ResearchIntelligenceReport
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              {
                workspace_id: workspace.id,
                generated_at: Time.current.iso8601,
                metrics: metrics,
                recommendations: recommendations
              }
            end

            private

            attr_reader :workspace

            def metrics
              {
                items: workspace.items.count,
                completed_items: workspace.items.where(
                  status: "completed"
                ).count,
                open_items: workspace.items.where.not(
                  status: "completed"
                ).count,
                entities: workspace.entity_count,
                questions: workspace.question_count,
                notes: workspace.note_count,
                evidence: evidence_count,
                annotations: annotation_count,
                verified_evidence: verified_evidence_count,
                reviewed_annotations: reviewed_annotation_count,
                evidence_coverage: safe_metric(:evidence_coverage),
                annotation_coverage: safe_metric(:annotation_coverage),
                research_strength: safe_metric(:research_strength)
              }
            end

            def recommendations
              result = []

              if workspace.items.where(
                kind: "question",
                status: "open"
              ).exists?
                result << recommendation(
                  "resolve-open-questions",
                  100,
                  "Resolve open research questions",
                  "Review unanswered questions and record supporting evidence."
                )
              end

              if evidence_count.zero? && workspace.items.exists?
                result << recommendation(
                  "collect-evidence",
                  95,
                  "Collect supporting evidence",
                  "Attach primary sources or reliable references to investigated items."
                )
              end

              if unverified_evidence_count.positive?
                result << recommendation(
                  "review-evidence",
                  85,
                  "Review evidence quality",
                  "Check source credibility, publication dates, and verification status."
                )
              end

              if unreviewed_annotations_count.positive?
                result << recommendation(
                  "review-annotations",
                  80,
                  "Review research annotations",
                  "Review active annotations and confirm or challenge their claims."
                )
              end

              if workspace.items.where(kind: "entity").count > 1
                result << recommendation(
                  "map-relationships",
                  70,
                  "Map relationships between entities",
                  "Compare investigated entities and record evidence for potential connections."
                )
              end

              if workspace.items.where(kind: "milestone").empty?
                result << recommendation(
                  "define-milestone",
                  60,
                  "Define an investigation milestone",
                  "Set a concrete next step that can be completed and verified."
                )
              end

              result.sort_by { |item| -item[:priority] }.first(10)
            end

            def recommendation(key, priority, title, description)
              {
                key: key,
                priority: priority,
                title: title,
                description: description
              }
            end

            def evidence_count
              workspace.research_evidences.count
            end

            def annotation_count
              workspace.research_annotations.count
            end

            def verified_evidence_count
              count_scope(:verified, workspace.research_evidences)
            end

            def unverified_evidence_count
              return 0 unless workspace.research_evidences.respond_to?(:verified)

              workspace.research_evidences
                       .where.not(id: workspace.research_evidences.verified.select(:id))
                       .count
            rescue ActiveRecord::ActiveRecordError
              0
            end

            def reviewed_annotation_count
              count_scope(:reviewed, workspace.research_annotations)
            end

            def unreviewed_annotations_count
              scope = workspace.research_annotations
              return 0 unless scope.respond_to?(:reviewed)

              scope.where.not(id: scope.reviewed.select(:id)).count
            rescue ActiveRecord::ActiveRecordError
              0
            end

            def count_scope(name, scope)
              return 0 unless scope.respond_to?(name)

              scope.public_send(name).count
            rescue ActiveRecord::ActiveRecordError
              0
            end

            def safe_metric(name)
              return 0 unless workspace.respond_to?(name)

              workspace.public_send(name)
            rescue ActiveRecord::ActiveRecordError,
              NoMethodError,
              ZeroDivisionError
              0
            end
          end
        end
      end
    end
  end
end