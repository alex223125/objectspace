# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationSemanticFact
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
            @type =
              normalize_type(type)

            @path =
              normalize_path(path)

            @identity =
              identity&.to_s

            @old_index =
              normalize_index(old_index)

            @new_index =
              normalize_index(new_index)

            @old_value =
              old_value

            @new_value =
              new_value

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

          def ==(other)
            return false unless other.is_a?(ApplicationSemanticFact)

            to_h == other.to_h
          end

          alias_method :eql?, :==

          def hash
            to_h.hash
          end

          private

          def normalize_type(value)
            case value.to_s.strip.downcase
            when "changed",
              "content_changed",
              "content_change"
              :content_change

            when "moved",
              "movement",
              "semantic_movement"
              :semantic_movement

            when "added",
              "added_entity"
              :added_entity

            when "removed",
              "removed_entity"
              :removed_entity

            when "warning",
              "identity_warning"
              :identity_warning

            else
              value.to_s.strip.downcase.to_sym
            end
          end

          def normalize_path(value)
            case value
            when Array
              value
                .flatten
                .compact
                .map(&:to_s)
                .flat_map do |part|
                normalize_string_path(part)
              end
                .reject(&:empty?)

            when nil
              []

            else
              normalize_string_path(value.to_s)
            end
          end

          def normalize_string_path(value)
            return [] if value.empty?

            value
              .gsub(/\[(\d+)\]/, '.\1')
              .split(".")
              .map(&:strip)
              .reject(&:empty?)
          end

          def normalize_index(value)
            return nil if value.nil?

            Integer(value)
          rescue ArgumentError, TypeError
            value.to_i
          end

          def normalize_metadata(value)
            return {} unless value.respond_to?(:to_h)

            deep_normalize(value.to_h)
          end

          def deep_normalize(value)
            case value
            when Hash
              value.each_with_object({}) do |(key, child), result|
                result[key.to_s] =
                  deep_normalize(child)
              end

            when Array
              value.map do |child|
                deep_normalize(child)
              end

            else
              value
            end
          end

          def validate!
            unless SUPPORTED_TYPES.include?(type)
              raise ArgumentError,
                    "Unsupported application semantic fact type: #{type.inspect}"
            end

            unless path.is_a?(Array)
              raise ArgumentError,
                    "Application semantic fact path must be an Array"
            end

            unless metadata.is_a?(Hash)
              raise ArgumentError,
                    "Application semantic fact metadata must be a Hash"
            end

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