# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityResolver
          Result = IdentityResolutionResult

          def initialize(identity_field:)
            @identity_field = identity_field.to_s
          end

          def call(old_array, new_array)
            IdentityResolution.call(
              old_array: old_array,
              new_array: new_array,
              identity_field: @identity_field
            )
          end
        end
      end
    end
  end
end