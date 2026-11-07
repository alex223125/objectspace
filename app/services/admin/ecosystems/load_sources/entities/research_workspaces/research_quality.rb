
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class ResearchQuality
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              items = workspace.items.to_a

              evidence = safe_relation do
                workspace.research_evidences.to_a
              end

              annotations = safe_relation do
                workspace.research_annotations.to_a
              end

              {
                items: items.length,
                evidence: evidence.length,
                annotations: annotations.length,
                evidence_coverage: coverage(items, evidence),
                annotation_coverage: coverage(items, annotations),
                verified_evidence: count_verified(evidence),
                disputed_evidence: count_disputed(evidence),
                high_confidence_evidence: count_high_confidence(evidence),
                average_evidence_confidence: average_confidence(evidence),
                research_strength: research_strength(items),
                recommendations: recommendations(
                  items,
                  evidence,
                  annotations
                )
              }
            end

            private

            attr_reader :workspace

            def safe_relation
              yield
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def coverage(items, records)
              return 0 if items.empty?

              researched_item_ids = records.map do |record|
                record.research_workspace_item_id
              end.compact.uniq

              ((items.count { |item|
                researched_item_ids.include?(item.id)
              }.to_f / items.length) * 100).round
            end

            def count_verified(records)
              records.count do |record|
                record.respond_to?(:verified?) && record.verified?
              end
            end

            def count_disputed(records)
              records.count do |record|
                value = record.respond_to?(:status) ? record.status : nil
                value.to_s == "disputed"
              end
            end

            def count_high_confidence(records)
              records.count do |record|
                next false unless record.respond_to?(:confidence)

                record.confidence.to_f >= 0.8
              end
            end

            def average_confidence(records)
              values = records.filter_map do |record|
                next unless record.respond_to?(:confidence)

                value = record.confidence
                next if value.nil?

                value.to_f
              end

              return 0 if values.empty?

              (values.sum / values.length.to_f).round(3)
            end

            def research_strength(items)
              return 0 if items.empty?

              values = items.filter_map do |item|
                item.research_strength.to_f if
                  item.respond_to?(:research_strength)
              end

              return 0 if values.empty?

              (values.sum / values.length.to_f).round
            end

            def recommendations(items, evidence, annotations)
              evidence_item_ids = evidence.map(
                &:research_workspace_item_id
              ).compact.uniq

              annotation_item_ids = annotations.map(
                &:research_workspace_item_id
              ).compact.uniq

              result = []

              missing_evidence = items.reject do |item|
                evidence_item_ids.include?(item.id)
              end

              if missing_evidence.any?
                result << {
                  key: "missing-evidence",
                  priority: 100,
                  kind: "evidence",
                  title: "Strengthen evidence coverage",
                  description:
                    "#{missing_evidence.length} research items have no linked evidence.",
                  action: "review_evidence"
                }
              end

              disputed = count_disputed(evidence)

              if disputed.positive?
                result << {
                  key: "disputed-evidence",
                  priority: 110,
                  kind: "verification",
                  title: "Review disputed evidence",
                  description:
                    "#{disputed} evidence records are marked as disputed.",
                  action: "review_disputed"
                }
              end

              unannotated = items.reject do |item|
                annotation_item_ids.include?(item.id)
              end

              if unannotated.any?
                result << {
                  key: "missing-annotations",
                  priority: 60,
                  kind: "annotation",
                  title: "Add research annotations",
                  description:
                    "#{unannotated.length} items have no linked annotations.",
                  action: "add_annotation"
                }
              end

              result.sort_by { |item| -item[:priority] }
            end
          end
        end
      end
    end
  end
end