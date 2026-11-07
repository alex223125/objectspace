# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class CrossEntityIntelligence
        class ActivityAnalysis

          def self.call(entity:, entities:)
            new(
              entity: entity,
              entities: entities
            ).call
          end

          def initialize(entity:, entities:)
            @entity = entity
            @entities = Array(entities)
          end

          def call
            activity = entities.map do |item|
              events =
                item.entity_events.to_a

              {
                entity_id: item.id,
                event_count: events.length,
                recent_event_count:
                  recent_events(events).length,
                last_activity_at:
                  events.max_by(&:occurred_at)&.occurred_at,
                activity_level:
                  activity_level(events)
              }
            end

            {
              entities:
                activity.sort_by do |item|
                  -item[:event_count]
                end,

              current:
                activity.find do |item|
                  item[:entity_id] == entity.id
                end
            }
          end

          private

          attr_reader :entity, :entities

          def recent_events(events)
            cutoff = 30.days.ago

            events.select do |event|
              event.occurred_at.present? &&
                event.occurred_at >= cutoff
            end
          end

          def activity_level(events)
            count =
              recent_events(events).length

            case count
            when 10..Float::INFINITY
              "high"
            when 4..9
              "medium"
            when 1..3
              "low"
            else
              "inactive"
            end
          end

        end
      end
    end
  end
end