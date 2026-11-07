# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        module Gamification
          class Signal
            TYPES = %w[
              change
              movement
              addition
              removal
              identity
              stability
            ].freeze

            attr_reader :type,
                        :key,
                        :title,
                        :description,
                        :points,
                        :severity,
                        :metadata

            def initialize(
              type:,
              key:,
              title:,
              description:,
              points:,
              severity: "info",
              metadata: {}
            )
              @type = type.to_s
              @key = key.to_s
              @title = title.to_s
              @description = description.to_s
              @points = points.to_i
              @severity = severity.to_s
              @metadata = metadata || {}

              validate!
            end

            def to_h
              {
                type: type,
                key: key,
                title: title,
                description: description,
                points: points,
                severity: severity,
                metadata: metadata
              }
            end

            private

            def validate!
              unless TYPES.include?(type)
                raise ArgumentError,
                      "Invalid gamification signal type: #{type.inspect}"
              end

              if points.negative?
                raise ArgumentError,
                      "Gamification signal points cannot be negative"
              end
            end
          end
        end
      end
    end
  end
end