
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class EntityVersionAdapter
            SNAPSHOT_FIELDS = %w[
              snapshot snapshot_data content data payload
              entity_data attributes_data
            ].freeze

            def call(version)
              return {} unless version

              attributes = model_attributes(version)
              snapshot = extract_snapshot(attributes)

              {
                "version_id" => read(version, :id)&.to_s,
                "entity_id" => read(version, :entity_id)&.to_s,
                "version_number" => read(version, :version_number),
                "created_at" => read(version, :created_at)&.iso8601,
                "updated_at" => read(version, :updated_at)&.iso8601,
                "author_id" => read(version, :user_id)&.to_s,
                "snapshot" => snapshot
              }
            end

            private

            def read(record, attribute)
              record.public_send(attribute) if record.respond_to?(attribute)
            end

            def model_attributes(record)
              if record.respond_to?(:attributes)
                record.attributes.stringify_keys
              elsif record.respond_to?(:to_h)
                record.to_h.stringify_keys
              else
                {}
              end
            rescue StandardError
              {}
            end

            def extract_snapshot(attributes)
              SNAPSHOT_FIELDS.each do |field|
                next unless attributes.key?(field)

                value = parse_value(attributes[field])
                return value.deep_stringify_keys if value.is_a?(Hash)
                return { "items" => value } if value.is_a?(Array)
              end

              attributes.except(
                "id", "entity_id", "version_number",
                "created_at", "updated_at", "user_id",
                "snapshot", "snapshot_data", "content",
                "data", "payload", "entity_data", "attributes_data"
              )
            end

            def parse_value(value)
              return value if value.is_a?(Hash) || value.is_a?(Array)
              return value unless value.is_a?(String) && value.present?

              JSON.parse(value)
            rescue JSON::ParserError
              value
            end
          end
        end
      end
    end
  end
end