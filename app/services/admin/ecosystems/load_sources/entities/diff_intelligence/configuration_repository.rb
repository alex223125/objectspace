# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ConfigurationRepository
          CONFIGURATION_KEY = "diff_intelligence"

          ConfigurationStorageUnavailable =
            Class.new(StandardError)

          def initialize(entity_template)
            @entity_template = entity_template
          end

          def load
            Configuration.new(
              array_identities:
                stored_configuration["array_identities"] || {}
            )
          end

          def save(configuration = nil, array_identities: nil)
            resolved =
              if configuration.is_a?(Configuration)
                configuration.to_h["array_identities"] || {}
              elsif array_identities
                array_identities
              elsif configuration.respond_to?(:to_h)
                hash = configuration.to_h

                hash["array_identities"] ||
                  hash[:array_identities] ||
                  {}
              else
                {}
              end

            normalized =
              normalize_array_identities(resolved)

            write_configuration(
              "array_identities" => normalized
            )

            load
          end

          private

          attr_reader :entity_template

          def stored_configuration
            raw =
              read_configuration

            case raw
            when Hash
              raw
            else
              {}
            end
          end

          def read_configuration
            metadata =
              if entity_template.respond_to?(:metadata)
                entity_template.metadata
              end

            return {} unless metadata.respond_to?(:[])

            metadata[CONFIGURATION_KEY] ||
              metadata[CONFIGURATION_KEY.to_sym] ||
              {}
          rescue StandardError => e
            raise ConfigurationStorageUnavailable,
                  "Unable to read Diff Intelligence configuration: #{e.message}"
          end

          def write_configuration(configuration)
            metadata =
              if entity_template.respond_to?(:metadata) &&
                entity_template.metadata.respond_to?(:to_h)

                entity_template.metadata
                               .to_h
                               .deep_dup
              else
                {}
              end

            metadata[CONFIGURATION_KEY] =
              configuration

            entity_template.update!(
              metadata: metadata
            )
          rescue ActiveRecord::RecordInvalid
            raise
          rescue StandardError => e
            raise ConfigurationStorageUnavailable,
                  "Unable to save Diff Intelligence configuration: #{e.message}"
          end

          def normalize_array_identities(value)
            return {} unless value.respond_to?(:to_h)

            value.to_h.each_with_object({}) do |(path, identity), result|
              normalized_path =
                normalize(path)

              normalized_identity =
                normalize(identity)

              next if normalized_path.blank?
              next if normalized_identity.blank?

              result[normalized_path] =
                normalized_identity
            end
          end

          def normalize(value)
            value.to_s
                 .strip
                 .gsub(/\A\.+|\.+\z/, "")
          end
        end
      end
    end
  end
end