# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFact
          TYPES = %i[
            content_change
            semantic_movement
            added_entity
            removed_entity
            identity_warning
          ].freeze

          attr_reader(
            :type,
            :path,
            :identity,
            :old_index,
            :new_index,
            :old_value,
            :new_value,
            :metadata
          )

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
            @type = normalize_type(type)

            @path =
              Array(path).map(&:to_s).freeze

            @identity =
              identity.nil? ? nil : identity.to_s

            @old_index = old_index
            @new_index = new_index
            @old_value = old_value
            @new_value = new_value
            @metadata = normalize_metadata(metadata).freeze

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

          def status
            case type
            when :content_change
              "changed"
            when :semantic_movement
              "moved"
            when :added_entity
              "added"
            when :removed_entity
              "removed"
            when :identity_warning
              "identity_warning"
            end
          end

          def to_h
            {
              type: type,
              status: status,
              path: path.join("."),
              identity: identity,
              old_index: old_index,
              new_index: new_index,
              old_value: old_value,
              new_value: new_value,
              metadata: metadata
            }.compact
          end

          private

          def normalize_type(value)
            normalized =
              case value
              when Symbol
                value
              when String
                value.to_sym
              else
                value
              end

            return normalized if TYPES.include?(normalized)

            raise ArgumentError,
                  "unsupported semantic fact type: #{value.inspect}"
          end

          def normalize_metadata(value)
            return {} if value.nil?

            value.each_with_object({}) do |(key, item), result|
              result[key.to_sym] = item
            end
          end

          def validate!
            if semantic_movement? &&
              (old_index.nil? || new_index.nil?)
              raise ArgumentError,
                    "semantic_movement requires old_index and new_index"
            end
          end
        end
      end
    end
  end
end