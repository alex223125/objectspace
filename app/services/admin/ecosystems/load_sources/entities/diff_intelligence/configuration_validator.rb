
# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ConfigurationValidator
          Result = Struct.new(
            :valid?,
            :errors,
            :configuration,
            keyword_init: true
          )

          DEFAULT_MAX_RULES = 50

          def self.call(value)
            new(value).call
          end

          def initialize(value)
            @value =
              if value.is_a?(Hash)
                value.deep_stringify_keys
              else
                {}
              end
          end

          def call
            errors = []
            normalized_rules = []

            rules = Array(@value["rules"])

            if rules.length > max_rules
              errors <<
                "A maximum of #{max_rules} identity rules is allowed."
            end

            rules.each_with_index do |raw_rule, index|
              validate_rule(
                raw_rule,
                index,
                normalized_rules,
                errors
              )
            end

            duplicate_paths =
              normalized_rules
                .group_by { |rule| rule["path"] }
                .select { |_path, items| items.length > 1 }
                .keys

            duplicate_paths.each do |path|
              errors << "Duplicate identity configuration for #{path}."
            end

            configuration =
              Configuration.new(
                "rules" => normalized_rules
              )

            Result.new(
              valid?: errors.empty?,
              errors: errors,
              configuration: configuration
            )
          end

          private

          def validate_rule(raw_rule, index, normalized_rules, errors)
            unless raw_rule.is_a?(Hash)
              errors << "Identity rule ##{index + 1} is invalid."
              return
            end

            rule = raw_rule.deep_stringify_keys

            path = rule["path"].to_s.strip
            identity = rule["identity"].to_s.strip

            if path.blank?
              errors << "Identity rule ##{index + 1} requires a path."
              return
            end

            unless valid_path?(path)
              errors <<
                "Identity rule ##{index + 1} contains an invalid path."
              return
            end

            unless valid_identities.include?(identity)
              errors <<
                "Identity rule ##{index + 1} uses an unsupported identity field."
              return
            end

            normalized_rules << {
              "path" => normalize_path(path),
              "identity" => identity
            }
          end

          def valid_identities
            configuration_constant(:VALID_IDENTITY_FIELDS, [])
          end

          def max_rules
            value = configuration_constant(
              :MAX_RULES,
              DEFAULT_MAX_RULES
            )

            Integer(value)
          rescue ArgumentError, TypeError
            DEFAULT_MAX_RULES
          end

          def configuration_constant(name, fallback)
            return fallback unless Configuration.const_defined?(name, false)

            Configuration.const_get(name, false)
          end

          def valid_path?(path)
            path.match?(
              /\A[a-zA-Z0-9_]+(?:\.[a-zA-Z0-9_]+)*\z/
            )
          end

          def normalize_path(path)
            path
              .strip
              .gsub(/\s+/, "")
              .gsub(/\.+/, ".")
              .sub(/\A\./, "")
              .sub(/\.\z/, "")
          end
        end
      end
    end
  end
end