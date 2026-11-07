# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        # Backwards-compatible facade around IdentityResolution.
        #
        # Existing SemanticComparator code can continue to call:
        #
        #   ArrayMatcher.new(...).call(...)
        #
        # while the actual identity logic lives in
        # IdentityResolution.
        class ArrayMatcher
          def initialize(identity_field:)
            @identity_field = identity_field
          end

          def call(old_array, new_array)
            IdentityResolution.call(
              old_array: old_array,
              new_array: new_array,
              identity_field: identity_field
            )
          end

          private

          attr_reader :identity_field
        end
      end
    end
  end
end