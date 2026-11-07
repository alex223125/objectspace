# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFact
          SUPPORTED_TYPES = %i[
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
        :old_value,
        :new_value,
        :old_index,
        :new_index,
        :metadata
      )

      def initialize(
        type:,
        path:,
        identity: nil,
        old_value: nil,
        new_value: nil,
        old_index: nil,
        new_index: nil,
        metadata: {}
      )
        @type =
          normalize_type(type)

        @path =
          normalize_path(path)

        @identity =
          identity.nil? ? nil : identity.to_s

        @old_value =
          old_value

        @new_value =
          new_value

        @old_index =
          normalize_index(old_index)

        @new_index =
          normalize_index(new_index)

        @metadata =
          normalize_metadata(metadata)

        validate!
      end

      SUPPORTED_TYPES.each do |semantic_type|
        define_method("#{semantic_type}?") do
          type == semantic_type
        end
      end

      def to_h
        {
          type: type,
          path: path,
          identity: identity,
          old_value: old_value,
          new_value: new_value,
          old_index: old_index,
          new_index: new_index,
          metadata: metadata
        }
      end

      def as_json(*)
        to_h
      end

      private

      def normalize_type(value)
        case value.to_s.to_sym
        when :changed,
          :content_changed
          :content_change

        when :moved,
          :movement
          :semantic_movement

        when :added
          :added_entity

        when :removed
          :removed_entity

        when :identity_issue,
          :duplicate_identity,
          :missing_identity,
          :ambiguous_identity,
          :warning
          :identity_warning

        else
          value.to_s.to_sym
        end
      end

      def normalize_path(value)
        case value
        when Array
          value
            .flatten
            .compact
            .flat_map do |part|
              normalize_path_part(part)
            end
            .reject(&:empty?)

        when nil
          []

        else
          normalize_path_part(value)
        end
      end

      def normalize_path_part(value)
        value
          .to_s
          .gsub(/\[(\d+)\]/, '.\1')
          .split(".")
          .map(&:strip)
          .reject(&:empty?)
      end

      def normalize_index(value)
        return nil if value.nil?

        Integer(value)
      rescue ArgumentError, TypeError
        raise ArgumentError,
              "Semantic fact index must be an Integer or nil"
      end

      def normalize_metadata(value)
        return {} unless value.respond_to?(:to_h)

        deep_normalize(value.to_h)
      end

      def deep_normalize(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, item), result|
            result[key.to_s] =
              deep_normalize(item)
          end

        when Array
          value.map do |item|
            deep_normalize(item)
          end

        else
          value
        end
      end

      def validate!
        unless SUPPORTED_TYPES.include?(type)
          raise ArgumentError,
                "Unsupported semantic fact type: #{type.inspect}"
        end

        if semantic_movement?
          if old_index.nil? || new_index.nil?
            raise ArgumentError,
                  "semantic_movement requires old_index and new_index"
          end
        end
      end
    end
  end
end

        end
      end
