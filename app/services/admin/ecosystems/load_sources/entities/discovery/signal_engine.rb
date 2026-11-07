# frozen_string_literal: true
module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class SignalEngine
            def initialize(entity)
              @entity = entity
            end

            def call
              signals = []

              neighbors = adapter.neighbors
              relationship_neighbors = adapter.relationship_neighbors

              connection_count =
                (neighbors + relationship_neighbors)
                  .uniq { |item| [item[:type], item[:id]] }
                  .length

              if connection_count >= 8
                signals << {
                  key: "ecosystem_hub",
                  icon: "🕸️",
                  title: "Ecosystem hub",
                  description: "This entity connects to many parts of the ecosystem.",
                  severity: "high",
                  score: 90
                }
              elsif connection_count >= 4
                signals << {
                  key: "connected",
                  icon: "🔗",
                  title: "Strongly connected",
                  description: "This entity has several discoverable relationships.",
                  severity: "medium",
                  score: 65
                }
              end

              if relationship_neighbors.any?
                signals << {
                  key: "persisted_relationships",
                  icon: "🎯",
                  title: "Relationship evidence",
                  description: "The ecosystem contains persisted relationship data for this entity.",
                  severity: "positive",
                  score: 85
                }
              end

              if neighbors.map { |item| item[:type] }.uniq.length >= 3
                signals << {
                  key: "cross_type",
                  icon: "🧭",
                  title: "Cross-type discovery",
                  description: "This entity connects across multiple entity categories.",
                  severity: "positive",
                  score: 80
                }
              end

              if signals.empty?
                signals << {
                  key: "discovery_opportunity",
                  icon: "✨",
                  title: "Discovery opportunity",
                  description: "Explore nearby entities to expand this investigation.",
                  severity: "low",
                  score: 40
                }
              end

              signals.sort_by { |signal| -signal[:score] }
            end

            private

            attr_reader :entity

            def adapter
              @adapter ||= EntityAdapter.new(entity)
            end
          end
        end
      end
    end
  end
end