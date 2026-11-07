# frozen_string_literal: true

module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class DiscoveryService
            def initialize(entity: nil, limit: 8)
              @entity = entity
              @limit = limit
            end

            def call
              Ecosystem::Discovery::Result.new(
                entity: entity,
                current_node: current_node,
                recommendations: recommendations,
                signals: signals,
                missions: missions,
                metrics: metrics
              )
            end

            private

            attr_reader :entity, :limit

            def recommendations
              return [] unless entity

              @recommendations ||= Ecosystem::Discovery::RecommendationEngine
                                     .new(entity: entity, limit: limit)
                                     .call
            end

            def signals
              return [] unless entity

              @signals ||= Ecosystem::Discovery::SignalEngine
                             .new(entity)
                             .call
            end

            def missions
              Ecosystem::Discovery::MissionEngine
                .new(entity: entity)
                .call
            end

            def current_node
              return nil unless entity

              {
                id: entity.id,
                type: entity.class.name.demodulize.underscore,
                name: display_name(entity)
              }
            end

            def metrics
              {
                recommendation_count: recommendations.length,
                signal_count: signals.length,
                mission_count: missions.length,
                discovery_score: discovery_score,
                explorer_xp_available: missions.sum { |mission| mission[:reward].to_i }
              }
            end

            def discovery_score
              return 0 unless entity

              recommendation_score =
                recommendations.sum { |item| item[:score].to_f }

              signal_score =
                signals.sum { |signal| signal[:score].to_f }

              ((recommendation_score + signal_score) / 2.0).round.clamp(0, 100)
            end

            def display_name(record)
              %i[name title label display_name].each do |attribute|
                next unless record.respond_to?(attribute)

                value = record.public_send(attribute)
                return value.to_s if value.present?
              end

              "#{record.class.name.demodulize} ##{record.id}"
            end
          end
        end
      end
    end
  end
end
