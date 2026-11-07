# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class GraphSummaryPresenter
          def initialize(metrics:, coverage:, health:)
            @metrics = metrics || {}
            @coverage = coverage || {}
            @health = health || {}
          end

          def call
            {
              title: "Relationship graph overview",
              status: read(@health, :status) || "unknown",
              generated_at: Time.current.iso8601,
              cards: [
                metric_card("Entities", :entity_count, "Distinct entity records"),
                metric_card("Relationships", :relationship_count, "Stored relationship records"),
                metric_card("Confirmed", :confirmed_relationship_count, "Relationships in the confirmed state"),
                metric_card("Suggested", :suggested_relationship_count, "Relationships awaiting review"),
                metric_card("Isolated", :isolated_entities, "Entities without recorded connections")
              ],
              coverage: {
                connected_entities: read(@coverage, :connected_entities) || 0,
                isolated_entities: read(@coverage, :isolated_entities) || 0,
                connected_entity_percent: read(@coverage, :connected_entity_percent) || 0.0
              },
              health_issues: read(@health, :issues) || [],
              disclaimer: "Metrics describe stored graph data. They do not independently verify factual accuracy."
            }
          end

          private

          def metric_card(label, metric_key, description)
            {
              label: label,
              value: read(@metrics, metric_key) || 0,
              description: description
            }
          end

          def read(hash, key)
            return nil unless hash.respond_to?(:[])

            hash[key] || hash[key.to_s]
          end
        end
      end
    end
  end
end