
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_change_feed_service.rb

require "set"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphChangeFeedService
            DEFAULT_LIMIT = 50
            MAX_LIMIT = 200

            DEFAULT_TIMESTAMP_FIELDS = %w[
              updated_at created_at imported_at reviewed_at
            ].freeze

            def initialize(nodes: [], edges: [], limit: DEFAULT_LIMIT,
                           timestamp_fields: DEFAULT_TIMESTAMP_FIELDS)
              @nodes = Array(nodes)
              @edges = Array(edges)
              @limit = [[limit.to_i, 1].max, MAX_LIMIT].min
              @timestamp_fields = Array(timestamp_fields).map(&:to_s)
            end

            def call
              events = build_events
              sorted = events.sort_by do |event|
                [event[:timestamp] || Time.at(0).utc, event[:record_id].to_s]
              end.reverse

              {
                events: sorted.first(@limit),
                total_events: sorted.size,
                returned_events: [sorted.size, @limit].min,
                truncated: sorted.size > @limit,
                generated_at: Time.current.iso8601
              }
            end

            private

            def build_events
              entity_events(@nodes) + relationship_events(@edges)
            end

            def entity_events(records)
              records.filter_map do |record|
                attributes = attributes_for(record)
                timestamp = timestamp_for(attributes)

                next unless timestamp

                {
                  event_type: "entity_updated",
                  record_type: record_type(record, "Entity"),
                  record_id: attributes["id"]&.to_s,
                  label: attributes["name"].presence || "Unnamed entity",
                  timestamp: timestamp,
                  status: attributes["status"],
                  summary: attributes["summary"],
                  source: "entity_record"
                }
              end
            end

            def relationship_events(records)
              records.filter_map do |record|
                attributes = attributes_for(record)
                timestamp = timestamp_for(attributes)

                next unless timestamp

                {
                  event_type: "relationship_updated",
                  record_type: record_type(record, "Relationship"),
                  record_id: attributes["id"]&.to_s,
                  label: relationship_label(attributes),
                  timestamp: timestamp,
                  source_id: attributes["source_entity_id"],
                  target_id: attributes["target_entity_id"],
                  status: attributes["status"],
                  source: "relationship_record"
                }
              end
            end

            def timestamp_for(attributes)
              @timestamp_fields.each do |field|
                value = attributes[field]
                next if value.blank?

                parsed = value.respond_to?(:to_time) ? value.to_time : Time.zone.parse(value.to_s)
                return parsed if parsed
              rescue ArgumentError, TypeError
                next
              end

              nil
            end

            def relationship_label(attributes)
              source = attributes["source_entity_id"]
              target = attributes["target_entity_id"]

              return "Relationship #{attributes['id']}" if source.blank? || target.blank?

              "#{source} → #{target}"
            end

            def attributes_for(record)
              if record.respond_to?(:attributes)
                record.attributes.stringify_keys
              elsif record.respond_to?(:to_h)
                record.to_h.stringify_keys
              else
                {}
              end
            end

            def record_type(record, fallback)
              record.class.name.presence || fallback
            end
          end
        end
      end
    end
  end
end