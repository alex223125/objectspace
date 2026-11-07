# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        module Compatibility
          unless const_defined?(:ResolveArrayIdentities, false)
            if Ecosystems::LoadSources::Entity::DiffIntelligence.const_defined?(
              :ResolveArrayIdentities,
              false
            )
              ResolveArrayIdentities =
                Ecosystems::LoadSources::Entity::DiffIntelligence::ResolveArrayIdentities
            end
          end
        end
      end
    end
  end
end
