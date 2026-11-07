# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class Configuration
          attr_reader :array_identities

          def initialize(array_identities: {})
            @array_identities =
              array_identities.each_with_object({}) do |(path, identity), result|
                result[canonical_path(path)] = identity.to_s
              end
          end

          def identity_for(path)
            @array_identities[canonical_path(path)]
          end

          private

          def canonical_path(path)
            Array(path.to_s.split("."))
              .reject(&:empty?)
              .join(".")
          end
        end
      end
    end
  end
end