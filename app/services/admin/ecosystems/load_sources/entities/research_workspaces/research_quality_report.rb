
# frozen_string_literal: true

module Admin
  module ResearchWorkspaces
    class ResearchQualityReport
      WEIGHTS = {
        verification: 40.0,
        confidence: 30.0,
        source_traceability: 20.0,
        annotation_coverage: 10.0
      }.freeze

      def initialize(workspace)
        @workspace = workspace
      end

      def call
        evidence = records_for(:research_evidences, item_association: :evidences)
        annotations = records_for(
          :research_annotations,
          item_association: :annotations
        )

        verified = evidence.count { |record| verified?(record) }
        disputed = evidence.count { |record| disputed?(record) }
        sourced = evidence.count { |record| sourced?(record) }
        active_annotations = annotations.count { |record| active?(record) }

        confidences = evidence.filter_map { |record| confidence_for(record) }

        score = calculate_score(
          evidence_count: evidence.size,
          verified_count: verified,
          sourced_count: sourced,
          confidences: confidences,
          annotation_count: annotations.size,
          active_annotation_count: active_annotations
        )

        {
          workspace_id: @workspace.id,
          score: score,
          rating: rating_for(score),
          methodology: {
            verification_weight: WEIGHTS[:verification],
            confidence_weight: WEIGHTS[:confidence],
            source_traceability_weight: WEIGHTS[:source_traceability],
            annotation_coverage_weight: WEIGHTS[:annotation_coverage],
            note: "Only available components contribute to the normalized score."
          },
          evidence: {
            total: evidence.size,
            verified: verified,
            disputed: disputed,
            unverified: evidence.size - verified,
            sourced: sourced
          },
          annotations: {
            total: annotations.size,
            active: active_annotations
          },
          confidence: {
            samples: confidences.size,
            average: confidences.any? ?
                       (confidences.sum / confidences.size).round(3) : nil
          },
          limitations: limitations(evidence, annotations, confidences)
        }
      end

      private

      def records_for(workspace_association, item_association:)
        records = association_records(@workspace, workspace_association)

        if records.nil?
          items = association_records(@workspace, :items)
          return [] if items.nil?

          records = items.flat_map do |item|
            association_records(item, item_association) || []
          end
        end

        records.uniq { |record| record.respond_to?(:id) ? record.id : record.object_id }
      end

      # nil means the association does not exist.
      # [] means the association exists but contains no records.
      def association_records(record, name)
        return nil unless record.class.reflect_on_association(name)

        record.public_send(name).to_a
      rescue NoMethodError
        nil
      end

      def verified?(record)
        return !!record.verified? if record.respond_to?(:verified?)

        status = value_for(record, :status).to_s
        return true if status == "verified"

        !!value_for(record, :verified)
      end

      def disputed?(record)
        return !!record.disputed? if record.respond_to?(:disputed?)

        value_for(record, :status).to_s == "disputed"
      end

      def sourced?(record)
        url = value_for(record, :source_url)
        name = value_for(record, :source_name)

        url.to_s.strip.present? || name.to_s.strip.present?
      end

      def active?(record)
        return !!record.active? if record.respond_to?(:active?)

        status = value_for(record, :status).to_s
        status.blank? || status == "active"
      end

      def confidence_for(record)
        value = value_for(record, :confidence)
        return nil if value.nil?

        number = Float(value)
        return nil unless number.finite?

        # Normalize 0..1 and 0..100 conventions.
        number = number / 100.0 if number > 1.0 && number <= 100.0
        return nil unless number.between?(0.0, 1.0)

        number
      rescue ArgumentError, TypeError
        nil
      end

      def value_for(record, attribute)
        return nil unless record.respond_to?(attribute)

        record.public_send(attribute)
      end

      def calculate_score(
        evidence_count:,
        verified_count:,
        sourced_count:,
        confidences:,
        annotation_count:,
        active_annotation_count:
      )
        return nil if evidence_count.zero?

        components = []

        components << [
          WEIGHTS[:verification],
          verified_count.to_f / evidence_count
        ]

        unless confidences.empty?
          components << [
            WEIGHTS[:confidence],
            confidences.sum / confidences.size
          ]
        end

        components << [
          WEIGHTS[:source_traceability],
          sourced_count.to_f / evidence_count
        ]

        unless annotation_count.zero?
          components << [
            WEIGHTS[:annotation_coverage],
            active_annotation_count.to_f / annotation_count
          ]
        end

        available_weight = components.sum(&:first)
        return nil if available_weight.zero?

        weighted = components.sum { |weight, value| weight * value }

        (100.0 * weighted / available_weight).round
      end

      def rating_for(score)
        return "insufficient_data" if score.nil?
        return "strong" if score >= 80
        return "developing" if score >= 55

        "needs_review"
      end

      def limitations(evidence, annotations, confidences)
        result = []
        result << "No evidence records are available." if evidence.empty?
        result << "No usable confidence values are available." if confidences.empty?
        result << "No annotations are available." if annotations.empty?

        result
      end
    end
  end
end