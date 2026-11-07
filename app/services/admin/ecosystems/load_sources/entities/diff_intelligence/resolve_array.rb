# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ResolveArray
          def self.call(
            old_items:,
            new_items:,
            path:,
            identity_key:
          )
            new(
              old_items: old_items,
              new_items: new_items,
              path: path,
              identity_key: identity_key
            ).call
          end

          def initialize(
            old_items:,
            new_items:,
            path:,
            identity_key:
          )
            @old_items = old_items
            @new_items = new_items
            @path = path
            @identity_key = identity_key
          end

          def call
            IdentityResolution.call(
              old_array: @old_items,
              new_array: @new_items,
              identity_field: @identity_key
            )
          end
        end
      end
    end
  end
end