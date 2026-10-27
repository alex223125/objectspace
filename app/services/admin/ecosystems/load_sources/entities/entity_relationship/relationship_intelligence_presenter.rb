# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipIntelligencePresenter

            def initialize(payload)
              @payload = payload
            end

            def as_json(*)
              {
                entity: payload[:entity],
                metrics: payload[:metrics],
                relationships:
                  payload[:relationships],
                nodes:
                  payload[:nodes],
                edges:
                  payload[:edges]
              }
            end

            private

            attr_reader :payload

          end
        end
      end
    end
  end
end