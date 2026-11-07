# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_evidence_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphEvidenceService
            DEFAULT_FIELDS = %w[
              id evidence source_url source_name
              citation description confidence created_at
            ].freeze

            def initialize(records:, fields: DEFAULT_FIELDS)
              @records = Array(records)
              @fields = Array(fields).map(&:to_s)
            end

            def call
              entries = @records.map do |record|
                attributes = attributes_for(record)

                evidence = @fields.each_with_object({}) do |field, result|
                  result[field] = attributes[field] if attributes.key?(field)
                end

                {
                  record_id: attributes["id"],
                  evidence: evidence,
                  has_evidence: evidence.any? do |key, value|
                    key != "id" && value.present?
                  end
                }
              end

              {
                record_count: entries.size,
                records_with_evidence: entries.count { |entry| entry[:has_evidence] },
                records_without_evidence: entries.count { |entry| !entry[:has_evidence] },
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