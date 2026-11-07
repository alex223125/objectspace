
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class EvidenceQualitySummary
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              {
                evidence: evidence_metrics,
                annotations: annotation_metrics
              }
            end

            private

            def evidence_metrics
              relation = association_relation(:research_evidences)
              return unavailable_metrics unless relation

              columns = relation.klass.column_names
              total = relation.count

              {
                available: true,
                total: total,
                verified: count_flag(relation, columns, %w[verified verified_at]),
                disputed: count_flag(relation, columns, %w[disputed disputed_at]),
                mean_confidence: mean_confidence(relation, columns)
              }
            end

            def annotation_metrics
              relation = association_relation(:research_annotations)
              return { available: false, total: 0, unresolved: nil } unless relation

              columns = relation.klass.column_names
              total = relation.count

              unresolved =
                if columns.include?("status")
                  relation.where(status: %w[open active unresolved pending]).count
                else
                  nil
                end

              { available: true, total: total, unresolved: unresolved }
            end

            def association_relation(name)
              reflection = @workspace.class.reflect_on_association(name)
              return nil unless reflection

              @workspace.public_send(name)
            end

            def count_flag(relation, columns, candidates)
              column = candidates.find { |name| columns.include?(name) }
              return nil unless column

              case column
              when "verified", "disputed"
                relation.where(column => true).count
              when "verified_at", "disputed_at"
                relation.where.not(column => nil).count
              end
            end

            def mean_confidence(relation, columns)
              return nil unless columns.include?("confidence")

              relation.where.not(confidence: nil).average(:confidence)&.to_f&.round(3)
            end

            def unavailable_metrics
              {
                available: false,
                total: 0,
                verified: nil,
                disputed: nil,
                mean_confidence: nil
              }
            end
          end
        end
      end
    end
  end
end