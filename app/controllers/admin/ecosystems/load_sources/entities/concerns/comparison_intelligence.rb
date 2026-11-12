# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ComparisonIntelligence
          extend ActiveSupport::Concern

          included do
            helper_method :comparison_intelligence_payload
          end

          private

          def prepare_comparison_intelligence(payload)
            @comparison_payload =
              comparison_intelligence_payload(payload)
          end

          def comparison_intelligence_payload(payload)
            payload = payload || {}

            changes =
              if payload.respond_to?(:[])
                payload[:changes] ||
                  payload["changes"] ||
                  payload[:differences] ||
                  payload["differences"] ||
                  []
              else
                []
              end

            {
              changes: changes
            }
          end
        end
      end
    end
  end
end