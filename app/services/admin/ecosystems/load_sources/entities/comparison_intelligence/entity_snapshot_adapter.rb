
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class EntitySnapshotAdapter
            SNAPSHOT_FIELDS = %w[
              snapshot
              content
              data
              payload
              attributes_data
              entity_data
              snapshot_data
            ].freeze

            IDENTITY_FIELDS = %w[
              id
              entity_id
              name
              slug
              entity_type
              status
              title
              description
              parent_id
            ].freeze

            def call(record)
              return {} unless record

              attributes = safe_attributes(record)
              snapshot = extract_snapshot(attributes)

              normalize_snapshot(snapshot, attributes)
            end

            private

            def safe_attributes(record)
              return record.attributes.stringify_keys if record.respond_to?(:attributes)

              if record.respond_to?(:to_h)
                record.to_h.stringify_keys
              else
                {}
              end
            rescue StandardError
              {}
            end

            def extract_snapshot(attributes)
              SNAPSHOT_FIELDS.each do |field|
                value = attributes[field]
                parsed = parse_serialized(value)

                return parsed if parsed.is_a?(Hash)
                return { "items" => parsed } if parsed.is_a?(Array)
              end

              attributes.slice(*IDENTITY_FIELDS)
            end

            def parse_serialized(value)
              return value if value.is_a?(Hash) || value.is_a?(Array)
              return nil unless value.is_a?(String) && value.present?

              JSON.parse(value)
            rescue JSON::ParserError
              nil
            end

            def normalize_snapshot(snapshot, attributes)
              result = snapshot.to_h.deep_stringify_keys

              IDENTITY_FIELDS.each do |field|
                next if result.key?(field)
                next unless attributes.key?(field)

                result[field] = attributes[field]
              end

              result
            end
          end
        end
      end
    end
  end
end