# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module RelationshipIntelligenceContext
        extend ActiveSupport::Concern

        private

        def load_relationship_intelligence(entity)
          @relationship_intelligence =
            RelationshipIntelligence
              .new(entity)
              .call
        end

        def load_ecosystem_intelligence
          @ecosystem_intelligence =
            EcosystemIntelligence
              .new
              .call
        end
      end
    end
  end
end