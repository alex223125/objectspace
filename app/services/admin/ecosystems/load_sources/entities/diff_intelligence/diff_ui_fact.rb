# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class DiffUIFact
          TYPES = %i[
            content_change
            semantic_movement
            added_entity
            removed_entity
            identity_warning
          ].freeze

          attr_reader \
            :type,
            :path,
            :identity,
            :old_index,
            :new_index,
            :old_value,
            :new_value,
            :metadata

          def initialize(
            type:,
            path:,
            identity: nil,
            old_index: nil,
            new_index: nil,
            old_value: nil,
            new_value: nil,
            metadata: {}
          )
            @type = type.to_sym
            @path = Array(path).map(&:to_s)
            @identity = identity
            @old_index = old_index
            @new_index = new_index
            @old_value = old_value
            @new_value = new_value
            @metadata = normalize_metadata(metadata)

            validate!
          end

          def content_change?
            type == :content_change
          end

          def semantic_movement?
            type == :semantic_movement
          end

          def added_entity?
            type == :added_entity
          end

          def removed_entity?
            type == :removed_entity
          end

          def identity_warning?
            type == :identity_warning
          end

          def path_string
            path.join(".")
          end

          def to_h
            {
              type: type,
              path: path,
              path_string: path_string,
              identity: identity,
              old_index: old_index,
              new_index: new_index,
              old_value: old_value,
              new_value: new_value,
              metadata: metadata
            }.compact
          end

          def as_json(*)
            to_h
          end

          private

          def normalize_metadata(value)
            return {} if value.nil?

            value.each_with_object({}) do |(key, item), result|
              result[key.to_s] = item
            end
          end

          def validate!
            unless TYPES.include?(type)
              raise ArgumentError,
                    "unsupported UI fact type: #{type.inspect}"
            end

            if semantic_movement? &&
              (!old_index.is_a?(Integer) || !new_index.is_a?(Integer))
              raise ArgumentError,
                    "semantic_movement requires old_index and new_index"
            end
          end
        end
      end
    end
  end
end