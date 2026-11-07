# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class DiffUIFact
        SUPPORTED_TYPES = %w[
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
          @path = normalize_path(path)
          @identity = normalize_identity(identity)
          @old_index = normalize_index(old_index)
          @new_index = normalize_index(new_index)
          @old_value = old_value
          @new_value = new_value
          @metadata = normalize_metadata(metadata)

          validate!
        end

        def content_change?
          type == "content_change"
        end

        def semantic_movement?
          type == "semantic_movement"
        end

        def added_entity?
          type == "added_entity"
        end

        def removed_entity?
          type == "removed_entity"
        end

        def identity_warning?
          type == "identity_warning"
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
          }
        end

        def as_json(*)
          to_h
        end

        private

        def normalize_type(value)
          value.to_s.strip.downcase
        end

        def normalize_path(value)
          case value
          when Array
            value
              .flatten
              .compact
              .map(&:to_s)
              .reject(&:empty?)
          when nil
            []
          else
            value
              .to_s
              .split(".")
              .map(&:strip)
              .reject(&:empty?)
          end
        end

        def normalize_identity(value)
          return nil if value.nil?

          value.to_s
        end

        def normalize_index(value)
          return nil if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          nil
        end

        def normalize_metadata(value)
          return {} unless value.respond_to?(:to_h)

          deep_normalize(value.to_h)
        end

        def deep_normalize(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, child), result|
              result[key.to_s] = deep_normalize(child)
            end
          when Array
            value.map { |child| deep_normalize(child) }
          else
            value
          end
        end

        def validate!
          unless SUPPORTED_TYPES.include?(type)
            raise ArgumentError,
                  "Unsupported UI diff fact type: #{type.inspect}"
          end

          unless path.is_a?(Array)
            raise ArgumentError,
                  "UI diff fact path must be an Array"
          end

          unless metadata.is_a?(Hash)
            raise ArgumentError,
                  "UI diff fact metadata must be a Hash"
          end
        end
      end
    end
  end
end