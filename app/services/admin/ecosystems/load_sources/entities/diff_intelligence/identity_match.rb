# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityMatch
          attr_reader :identity,
                      :old_index,
                      :new_index,
                      :old_object,
                      :new_object

          def initialize(
            identity:,
            old_index:,
            new_index:,
            old_object:,
            new_object:
          )
            @identity = identity
            @old_index = old_index
            @new_index = new_index
            @old_object = old_object
            @new_object = new_object
          end

          def moved?
            old_index != new_index
          end

          def unchanged_position?
            !moved?
          end

          def to_h
            {
              identity: identity,
              old_index: old_index,
              new_index: new_index,
              moved: moved?
            }
          end
        end
      end
    end
  end
end