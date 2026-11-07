# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ComparisonRequest
          attr_reader :old_snapshot, :new_snapshot, :configuration

          def initialize(
            old_snapshot:,
            new_snapshot:,
            configuration:
          )
            @old_snapshot = old_snapshot
            @new_snapshot = new_snapshot
            @configuration = configuration

            validate!
          end

          private

          def validate!
            unless old_snapshot.is_a?(Hash)
              raise ArgumentError,
                    "old_snapshot must be a Hash"
            end

            unless new_snapshot.is_a?(Hash)
              raise ArgumentError,
                    "new_snapshot must be a Hash"
            end

            unless configuration.respond_to?(:array_identities)
              raise ArgumentError,
                    "configuration must expose array_identities"
            end
          end
        end
      end
    end
  end
end