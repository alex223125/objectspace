# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityConfiguration
          attr_reader :rules

          def initialize(rules: {})
            @rules = normalize_rules(rules)
          end

          def identity_key_for(path)
            normalized_path = normalize_path(path)

            rules[normalized_path]
          end

          def configured?(path)
            identity_key_for(path).present?
          end

          def to_h
            {
              rules: rules.dup
            }
          end

          private

          def normalize_rules(value)
            value.each_with_object({}) do |(path, identity_key), result|
              result[path.to_s] = identity_key.to_s
            end
          end

          def normalize_path(path)
            path
              .to_s
              .sub(/\[\d+\]\z/, "")
          end
        end
      end
    end
  end
end