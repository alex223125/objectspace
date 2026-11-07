# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationFact
          TYPES = %i[
            content_change
            semantic_movement
            added_entity
            removed_entity
            identity_warning
          ].freeze

          attr_reader :type, :path, :old_value, :new_value, :metadata

          def initialize(
            type:,
            path: [],
            old_value: nil,
            new_value: nil,
            metadata: {}
          )
            @type = normalize_type(type)
            @path = normalize_path(path)
            @old_value = old_value
            @new_value = new_value
            @metadata = normalize_metadata(metadata)
          end

          def to_h
            {
              type: type,
              path: path,
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
            normalized = value.to_sym

            unless TYPES.include?(normalized)
              raise ArgumentError,
                    "Unsupported semantic fact type: #{normalized.inspect}"
            end

            normalized
          rescue NoMethodError
            raise ArgumentError,
                  "Semantic fact type must be symbol-like"
          end

          def normalize_path(value)
            Array(value).map do |part|
              case part
              when Integer
                part
              else
                part.to_s
              end
            end.freeze
          end

          def normalize_metadata(value)
            hash =
              if value.respond_to?(:to_h)
                value.to_h
              else
                {}
              end

            hash
              .each_with_object({}) do |(key, child), result|
              result[key.to_sym] = child
            end
              .sort_by { |key, _| key.to_s }
              .to_h
              .freeze
          end
        end
      end
    end
  end
end