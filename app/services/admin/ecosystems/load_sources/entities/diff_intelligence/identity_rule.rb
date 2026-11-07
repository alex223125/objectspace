# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        module DiffIntelligence
          class IdentityRule
            attr_reader :path, :field

            def initialize(path:, field:)
              @path = normalize_path(path)
              @field = field.to_s
            end

            def applicable_to?(array_path)
              normalize_path(array_path) == path
            end

            private

            def normalize_path(path)
              Array(path)
                .map(&:to_s)
                .reject(&:blank?)
                .join(".")
            end
          end
        end
    end
  end
  end
end
