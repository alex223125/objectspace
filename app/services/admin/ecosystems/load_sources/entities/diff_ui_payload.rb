# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class DiffUIPayload
        VERSION = 1

        attr_reader :representation

        def self.call(diff)
          representation =
            if diff.is_a?(DiffUIRepresentation)
              diff
            else
              DiffUIRepresentation.call(diff)
            end

          new(representation).call
        end

        def initialize(representation)
          @representation = representation
        end

        def call
          {
            version: VERSION,
            summary: representation.summary,
            changes: representation.changes.map(&:to_h),
            movements: representation.movements.map(&:to_h),
            additions: representation.additions.map(&:to_h),
            removals: representation.removals.map(&:to_h),
            warnings: representation.warnings.map(&:to_h)
          }
        end

        def to_h
          call
        end

        def as_json(*)
          to_h
        end
      end
    end
  end
end