# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_provenance_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphProvenanceService
            DEFAULT_FIELDS = %w[
              id source source_type source_id source_url
              created_at updated_at imported_at
            ].freeze

            def initialize(records:, fields: DEFAULT_FIELDS)
              @records = Array(records)
              @fields = Array(fields).map(&:to_s)
            end

            def call
              entries = @records.map do |record|
                attributes = attributes_for(record)

                {
                  record_id: attributes["id"],
                  provenance: @fields.each_with_object({}) do |field, result|
                    result[field] = attributes[field] if attributes.key?(field)
                  end,
                  available_fields: @fields.select { |field| attributes.key?(field) }
                }
              end

              {
                record_count: entries.size,
                records_with_provenance: entries.count do |entry|
                  entry[:provenance].any? do |key, value|
                    key != "id" && value.present?
                  end
                end,
                entries: entries,
                generated_at: Time.current.iso8601
              }
            end

            private

            def attributes_for(record)
              if record.respond_to?(:attributes)
                record.attributes
              elsif record.respond_to?(:to_h)
                record.to_h.stringify_keys
              else
                {}
              end
            end
          end
        end
      end
    end
  end
end