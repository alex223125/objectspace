# frozen_string_literal: true

module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class Result
            attr_reader :entity,
                        :recommendations,
                        :signals,
                        :missions,
                        :metrics,
                        :current_node

            def initialize(
              entity: nil,
              recommendations: [],
              signals: [],
              missions: [],
              metrics: {},
              current_node: nil
            )
              @entity = entity
              @recommendations = recommendations
              @signals = signals
              @missions = missions
              @metrics = metrics
              @current_node = current_node
            end

            def as_json(*)
              {
                entity: entity_payload,
                current_node: current_node,
                recommendations: recommendations,
                signals: signals,
                missions: missions,
                metrics: metrics
              }
            end

            private

            def entity_payload
              return nil unless entity

              {
                id: entity.id,
                type: entity.class.name,
                name: discovery_name(entity),
                url: entity_url(entity)
              }
            end

            def discovery_name(record)
              %i[name title label display_name slug].each do |attribute|
                next unless record.respond_to?(attribute)

                value = record.public_send(attribute)
                return value.to_s if value.present?
              end

              "#{record.class.name.demodulize} ##{record.id}"
            end

            def entity_url(record)
              return nil unless Rails.application.routes.url_helpers.respond_to?(:polymorphic_path)

              Rails.application.routes.url_helpers.polymorphic_path(record)
            rescue StandardError
              nil
            end
          end
        end
      end
    end
  end
end