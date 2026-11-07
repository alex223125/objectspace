
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class ResearchIntegrityReport
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              evidence = evidence_records
              annotations = annotation_records

              verified = evidence.count { |record| verified?(record) }
              disputed = evidence.count { |record| disputed?(record) }
              missing_source = evidence.count do |record|
                missing_provenance?(record)
              end

              {
                workspace_id: workspace.id,
                evidence: {
                  total: evidence.size,
                  verified: verified,
                  unverified: evidence.size - verified,
                  disputed: disputed,
                  missing_provenance: missing_source,
                  average_confidence: average_confidence(evidence)
                },
                annotations: {
                  total: annotations.size,
                  active: annotations.count { |record| active?(record) },
                  unresolved: annotations.count do |record|
                    unresolved?(record)
                  end,
                  average_confidence: average_confidence(annotations)
                },
                quality: {
                  evidence_verification_percent: percentage(
                    verified,
                    evidence.size
                  ),
                  provenance_completeness_percent: percentage(
                    evidence.size - missing_source,
                    evidence.size
                  ),
                  research_strength: research_strength(
                    evidence,
                    annotations,
                    verified,
                    disputed,
                    missing_source
                  )
                },
                generated_at: Time.current.iso8601
              }
            end

            private

            attr_reader :workspace

            def evidence_records
              if workspace.respond_to?(:research_evidences)
                return workspace.research_evidences.to_a
              end

              workspace.items.flat_map do |item|
                item.respond_to?(:evidences) ? item.evidences.to_a : []
              end
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def annotation_records
              if workspace.respond_to?(:research_annotations)
                return workspace.research_annotations.to_a
              end

              workspace.items.flat_map do |item|
                item.respond_to?(:annotations) ? item.annotations.to_a : []
              end
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def verified?(record)
              return record.verified? if record.respond_to?(:verified?)

              if record.respond_to?(:verified)
                return record.verified == true
              end

              return true if record.respond_to?(:verified_at) &&
                record.verified_at.present?

              record.respond_to?(:status) &&
                record.status.to_s == "verified"
            end

            def disputed?(record)
              record.respond_to?(:status) &&
                record.status.to_s == "disputed"
            end

            def active?(record)
              return record.active? if record.respond_to?(:active?)

              !%w[archived rejected deleted].include?(
                record.respond_to?(:status) ? record.status.to_s : ""
              )
            end

            def unresolved?(record)
              status = record.respond_to?(:status) ?
                         record.status.to_s : ""

              !%w[resolved rejected archived].include?(status)
            end

            def missing_provenance?(record)
              source_name = read_attribute(record, :source_name)
              source_url = read_attribute(record, :source_url)
              source_id = read_attribute(record, :source_id)

              source_name.blank? &&
                source_url.blank? &&
                source_id.blank?
            end

            def read_attribute(record, name)
              return unless record.respond_to?(name)

              record.public_send(name)
            end

            def average_confidence(records)
              values = records.filter_map do |record|
                next unless record.respond_to?(:confidence)

                Float(record.confidence)
              rescue ArgumentError, TypeError
                nil
              end

              return nil if values.empty?

              (values.sum / values.size).round(2)
            end

            def percentage(numerator, denominator)
              return 0 if denominator.zero?

              ((numerator.to_f / denominator) * 100).round
            end

            def research_strength(
              evidence,
              annotations,
              verified,
              disputed,
              missing_source
            )
              return 0 if evidence.empty? && annotations.empty?

              evidence_score =
                if evidence.empty?
                  0
                else
                  verification = verified.to_f / evidence.size
                  provenance =
                    (evidence.size - missing_source).to_f / evidence.size

                  ((verification * 60) + (provenance * 40)).round
                end

              penalty = if evidence.empty?
                          0
                        else
                          (disputed.to_f / evidence.size * 30).round
                        end

              annotation_score =
                if annotations.empty?
                  0
                else
                  (annotations.count { |record| active?(record) }.to_f /
                    annotations.size * 100).round
                end

              weighted =
                if evidence.empty?
                  annotation_score
                elsif annotations.empty?
                  evidence_score
                else
                  (evidence_score * 0.8 + annotation_score * 0.2).round
                end

              [[weighted - penalty, 0].max, 100].min
            end
          end
        end
      end
    end
  end
end