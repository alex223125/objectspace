
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ProvenanceService
            def initialize(events:)
              @events = Array(events)
            end

            def call
              timeline = events.map.with_index do |event, index|
                data = normalize(event)

                {
                  id: data[:id] || "event-#{index + 1}",
                  event_type: data[:event_type] || "unknown",
                  occurred_at: data[:occurred_at],
                  actor: data[:actor],
                  source: data[:source],
                  entity_id: data[:entity_id],
                  revision_id: data[:revision_id],
                  metadata: data[:metadata] || {}
                }
              end

              {
                total: timeline.length,
                timeline: timeline.sort_by do |item|
                  item[:occurred_at].to_s
                end
              }
            end

            private

            attr_reader :events

            def normalize(event)
              data = event.respond_to?(:attributes) ? event.attributes : event.to_h
              data = data.stringify_keys

              {
                id: data["id"],
                event_type: data["event_type"] || data["action"] || data["type"],
                occurred_at: data["occurred_at"] || data["created_at"],
                actor: data["actor"] || data["user_id"],
                source: data["source"] || data["source_id"],
                entity_id: data["entity_id"],
                revision_id: data["revision_id"] || data["entity_version_id"],
                metadata: data["metadata"].is_a?(Hash) ? data["metadata"] : {}
              }
            rescue NoMethodError
              {}
            end
          end
        end
      end
    end
  end
end