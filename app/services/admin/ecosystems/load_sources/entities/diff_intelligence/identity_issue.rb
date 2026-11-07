# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityIssue
          TYPES = %w[
            missing_identity
            duplicate_identity
            ambiguous_identity
          ].freeze

          SEVERITIES = %w[
            warning
            error
          ].freeze

          attr_reader :type,
                      :path,
                      :identity_key,
                      :identity_value,
                      :indexes,
                      :side,
                      :message,
                      :severity

          def initialize(
            type:,
            path:,
            identity_key:,
            identity_value: nil,
            indexes: [],
            side:,
            message:,
            severity: "warning"
          )
            @type = type.to_s
            @path = path.to_s
            @identity_key = identity_key.to_s
            @identity_value = identity_value
            @indexes = Array(indexes)
            @side = side.to_s
            @message = message.to_s
            @severity = severity.to_s

            validate!
          end

          def missing_identity?
            type == "missing_identity"
          end

          def duplicate_identity?
            type == "duplicate_identity"
          end

          def ambiguous_identity?
            type == "ambiguous_identity"
          end

          def error?
            severity == "error"
          end

          def to_h
            {
              type: type,
              path: path,
              identity_key: identity_key,
              identity_value: identity_value,
              indexes: indexes,
              side: side,
              message: message,
              severity: severity
            }
          end

          private

          def validate!
            unless TYPES.include?(type)
              raise ArgumentError,
                    "Invalid identity issue type: #{type.inspect}"
            end

            unless SEVERITIES.include?(severity)
              raise ArgumentError,
                    "Invalid identity issue severity: #{severity.inspect}"
            end

            unless %w[old new].include?(side)
              raise ArgumentError,
                    "Identity issue side must be old or new"
            end
          end
        end
      end
    end
  end
end