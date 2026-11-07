
# frozen_string_literal: true

require "csv"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ExportService
            CSV_COLUMNS = %w[
              id path type risk magnitude reviewed
              old_value new_value description
            ].freeze

            def initialize(changes:, metadata: {})
              @changes = Array(changes).map do |item|
                item.to_h.stringify_keys
              end
              @metadata = metadata.to_h.stringify_keys
            end

            def call(format:)
              case format.to_s.downcase
              when "csv"
                {
                  filename: filename("csv"),
                  content_type: "text/csv; charset=utf-8",
                  body: csv_body
                }
              when "json"
                {
                  filename: filename("json"),
                  content_type: "application/json; charset=utf-8",
                  body: JSON.pretty_generate(
                    metadata: @metadata,
                    total: @changes.length,
                    changes: @changes
                  )
                }
              else
                raise ArgumentError, "Unsupported export format"
              end
            end

            private

            def csv_body
              CSV.generate(headers: true) do |csv|
                csv << CSV_COLUMNS

                @changes.each do |change|
                  csv << CSV_COLUMNS.map do |column|
                    safe_csv_value(change[column])
                  end
                end
              end
            end

            def safe_csv_value(value)
              text = value.to_s

              # Prevent spreadsheet applications from evaluating
              # exported text as a formula.
              text = "'#{text}" if text.match?(/\A[\s]*[=+\-@]/)

              text
            end

            def filename(extension)
              date = Time.current.utc.strftime("%Y%m%d-%H%M%S")
              "comparison-intelligence-#{date}.#{extension}"
            end
          end
        end
      end
    end
  end
end