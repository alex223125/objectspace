# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module CrossEntityIntelligence

      class Refresh

        def self.call(entity, async: false)
          new(
            entity,
            async: async
          ).call
        end

        def initialize(entity, async:)
          @entity = entity
          @async = async
        end

        def call
          return unless entity&.persisted?

          if async
            RelationshipDiscoveryJob.perform_later(
              entity.id
            )

            return :queued
          end

          RelationshipDiscovery.call(entity)

          :completed
        end

        private

        attr_reader :entity, :async

      end

    end
  end
end