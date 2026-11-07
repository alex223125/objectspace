
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class SourceReliabilityService
            WEIGHTS = {
              editorial_review: 25,
              author_identified: 15,
              primary_source: 20,
              independent_corroboration: 20,
              correction_policy: 10,
              provenance_documented: 10
            }.freeze

            def initialize(sources:)
              @sources = Array(sources)
            end

            def call
              results = sources.map do |source|
                data = normalize(source)

                breakdown = WEIGHTS.transform_values.with_index do |weight, _index|
                  weight
                end

                earned = WEIGHTS.sum do |key, weight|
                  data[key] ? weight : 0
                end

                {
                  id: data[:id],
                  name: data[:name],
                  score: earned,
                  maximum_score: WEIGHTS.values.sum,
                  signals: WEIGHTS.keys.index_with { |key| data[key] },
                  missing_signals: WEIGHTS.keys.reject { |key| data[key] },
                  level: level_for(earned)
                }
              end

              {
                total: results.length,
                average_score: results.empty? ? 0 : (results.sum { |item| item[:score] }.to_f / results.length).round,
                sources: results
              }
            end

            private

            attr_reader :sources

            def normalize(source)
              data = source.respond_to?(:to_h) ? source.to_h : {}
              data = data.stringify_keys

              WEIGHTS.keys.each_with_object(
                { id: data["id"], name: data["name"] || data["title"] }
              ) do |key, result|
                result[key] = ActiveModel::Type::Boolean.new.cast(data[key.to_s])
              end
            end

            def level_for(score)
              case score
              when 80..100 then "strong_signals"
              when 55..79 then "moderate_signals"
              when 30..54 then "limited_signals"
              else "insufficient_signals"
              end
            end
          end
        end
      end
    end
  end
end