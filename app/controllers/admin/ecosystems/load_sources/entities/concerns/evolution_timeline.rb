# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EvolutionTimeline
          extend ActiveSupport::Concern

          included do
            helper_method :comparison_timeline_payload
          end

          private

          def prepare_comparison_timeline(
            entity:,
            old_version:,
            new_version:,
            versions: nil
          )
            @comparison_timeline_payload =
              build_comparison_timeline_payload(
                entity: entity,
                old_version: old_version,
                new_version: new_version,
                versions: versions
              )
          end

          def comparison_timeline_payload
            @comparison_timeline_payload || {
              versions: []
            }
          end
        end
      end
    end
  end
end