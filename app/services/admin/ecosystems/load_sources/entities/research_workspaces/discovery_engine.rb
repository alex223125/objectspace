
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class DiscoveryEngine
            Result = Struct.new(
              :recommendations,
              :metrics,
              keyword_init: true
            )

            def initialize(workspace)
              @workspace = workspace
            end

            def call
              current_recommendations = recommendations

              Result.new(
                recommendations: current_recommendations,
                metrics: metrics(current_recommendations.length)
              )
            end

            private

            attr_reader :workspace

            def recommendations
              (
                open_questions +
                  relationship_opportunities +
                  workspace_milestones +
                  evidence_recommendations +
                  annotation_recommendations
              )
                .uniq { |item| item[:key] }
                .sort_by { |item| -item[:priority].to_i }
                .first(8)
            end

            def open_questions
              workspace.items
                       .where(kind: "question", status: "open")
                       .order(:position, :created_at)
                       .limit(3)
                       .map do |item|
                {
                  key: "question-#{item.id}",
                  kind: "question",
                  priority: 100,
                  title: item.title,
                  description: "Resolve this open research question.",
                  action: "focus",
                  item_id: item.id
                }
              end
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def relationship_opportunities
              return [] unless workspace.items.where(
                kind: "entity"
              ).exists?

              [
                {
                  key: "relationship-exploration",
                  kind: "relationship",
                  priority: 70,
                  title: "Explore relationships between entities",
                  description: "Review investigated entities and identify potential connections.",
                  action: "add_relationship"
                }
              ]
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def workspace_milestones
              return [] if workspace.items.where(
                kind: "milestone"
              ).exists?

              [
                {
                  key: "milestone-start",
                  kind: "milestone",
                  priority: 60,
                  title: "Define the investigation question",
                  description: "Create a research question to establish the investigation's direction.",
                  action: "create_question"
                }
              ]
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def evidence_recommendations
              stats = evidence_statistics

              results = []

              if stats[:total].zero? && item_count.positive?
                results << {
                  key: "evidence-missing",
                  kind: "evidence",
                  priority: 90,
                  title: "Attach supporting evidence",
                  description: "This investigation contains research items but no evidence records.",
                  action: "add_evidence"
                }
              elsif stats[:unverified].positive?
                results << {
                  key: "evidence-verification",
                  kind: "evidence",
                  priority: 85,
                  title: "Review unverified evidence",
                  description: "#{stats[:unverified]} evidence record(s) still need verification.",
                  action: "verify_evidence"
                }
              end

              if stats[:disputed].positive?
                results << {
                  key: "evidence-disputed",
                  kind: "evidence",
                  priority: 95,
                  title: "Resolve disputed evidence",
                  description: "#{stats[:disputed]} evidence record(s) are disputed.",
                  action: "review_disputed_evidence"
                }
              end

              results
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def annotation_recommendations
              annotations = workspace.items.includes(:annotations)
              active_count = annotations.sum do |item|
                item.annotations.count do |annotation|
                  active_annotation?(annotation)
                end
              end

              return [] if active_count.positive?

              [
                {
                  key: "annotation-missing",
                  kind: "annotation",
                  priority: 45,
                  title: "Record research findings",
                  description: "Add annotations to capture observations, reasoning, and conclusions.",
                  action: "add_annotation"
                }
              ]
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def metrics(recommendation_count)
              evidence = evidence_statistics
              annotations = annotation_statistics

              {
                items: item_count,
                completed: workspace.items.where(
                  status: "completed"
                ).count,
                progress: workspace.progress,
                entities: workspace.entity_count,
                questions: workspace.question_count,
                notes: workspace.note_count,
                recommendations: recommendation_count,
                evidence: evidence,
                annotations: annotations,
                research_integrity: research_integrity(
                  evidence,
                  annotations
                )
              }
            rescue ActiveRecord::ActiveRecordError
              {
                items: 0,
                completed: 0,
                progress: 0,
                entities: 0,
                questions: 0,
                notes: 0,
                recommendations: recommendation_count,
                evidence: empty_evidence_statistics,
                annotations: {
                  total: 0,
                  active: 0,
                  resolved: 0
                },
                research_integrity: {
                  score: 0,
                  grade: "insufficient_data"
                }
              }
            end

            def evidence_statistics
              evidence_records = all_evidence_records

              verified = evidence_records.count do |record|
                verified_evidence?(record)
              end

              disputed = evidence_records.count do |record|
                disputed_evidence?(record)
              end

              with_source = evidence_records.count do |record|
                source_present?(record)
              end

              confidences = evidence_records.filter_map do |record|
                confidence_value(record)
              end

              total = evidence_records.length

              {
                total: total,
                verified: verified,
                unverified: total - verified - disputed,
                disputed: disputed,
                with_source: with_source,
                verification_percent: percentage(verified, total),
                provenance_percent: percentage(with_source, total),
                average_confidence: confidences.any? ?
                                      (confidences.sum / confidences.length).round(3) : nil
              }
            end

            def annotation_statistics
              records = all_annotation_records

              active = records.count do |record|
                active_annotation?(record)
              end

              {
                total: records.length,
                active: active,
                resolved: records.length - active
              }
            end

            def all_evidence_records
              workspace.items.includes(:evidences).flat_map do |item|
                item.evidences.to_a
              end
            end

            def all_annotation_records
              workspace.items.includes(:annotations).flat_map do |item|
                item.annotations.to_a
              end
            end

            def verified_evidence?(record)
              return record.verified? if record.respond_to?(:verified?)

              if record.respond_to?(:has_attribute?) &&
                record.has_attribute?("verified_at")
                return record.verified_at.present?
              end

              if record.respond_to?(:has_attribute?) &&
                record.has_attribute?("is_verified")
                return record.is_verified == true
              end

              if record.respond_to?(:has_attribute?) &&
                record.has_attribute?("verified")
                return record.verified == true
              end

              record.respond_to?(:status) &&
                record.status.to_s == "verified"
            end

            def disputed_evidence?(record)
              record.respond_to?(:status) &&
                record.status.to_s == "disputed"
            end

            def source_present?(record)
              url = record.respond_to?(:source_url) ?
                      record.source_url : nil

              name = record.respond_to?(:source_name) ?
                       record.source_name : nil

              url.present? || name.present?
            end

            def confidence_value(record)
              return unless record.respond_to?(:confidence)

              value = Float(record.confidence, exception: false)
              return unless value&.finite?

              [[value, 0.0].max, 1.0].min
            end

            def active_annotation?(record)
              return record.active? if record.respond_to?(:active?)

              return false if record.respond_to?(:status) &&
                %w[resolved rejected archived].include?(
                  record.status.to_s
                )

              true
            end

            def research_integrity(evidence, annotations)
              total = evidence[:total]

              return {
                score: 0,
                grade: "insufficient_data"
              } if total.zero?

              # Explicit, explainable quality components:
              # verification 45%, source traceability 35%, confidence 20%.
              confidence = evidence[:average_confidence] || 0.0

              score = (
                evidence[:verification_percent] * 0.45 +
                  evidence[:provenance_percent] * 0.35 +
                  confidence * 100 * 0.20
              ).round

              {
                score: score,
                grade: integrity_grade(score),
                verified_evidence: evidence[:verified],
                disputed_evidence: evidence[:disputed],
                annotations: annotations[:total]
              }
            end

            def integrity_grade(score)
              case score
              when 85..100 then "strong"
              when 65..84 then "moderate"
              when 40..64 then "developing"
              else "weak"
              end
            end

            def item_count
              @item_count ||= workspace.items.count
            end

            def percentage(numerator, denominator)
              return 0 if denominator.zero?

              (numerator.to_f / denominator * 100).round
            end

            def empty_evidence_statistics
              {
                total: 0,
                verified: 0,
                unverified: 0,
                disputed: 0,
                with_source: 0,
                verification_percent: 0,
                provenance_percent: 0,
                average_confidence: nil
              }
            end
          end
        end
      end
    end
  end
end