# frozen_string_literal: true
module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class RecommendationEngine
            DEFAULT_LIMIT = 8

            def initialize(entity:, limit: DEFAULT_LIMIT)
              @entity = entity
              @limit = [[limit.to_i, 1].max, 25].min
            end

            def call
              candidates = collect_candidates

              ranked = candidates
                         .group_by { |candidate| [candidate[:type], candidate[:id]] }
                         .map { |_key, records| merge_candidate(records) }
                         .sort_by { |candidate| -candidate[:score] }
                         .first(limit)

              ranked.each_with_index do |candidate, index|
                candidate[:rank] = index + 1
              end

              ranked
            end

            private

            attr_reader :entity, :limit

            def collect_candidates
              adapter.neighbors + adapter.relationship_neighbors
            end

            def merge_candidate(records)
              strongest = records.max_by { |record| record[:confidence].to_f }

              score = calculate_score(records)

              {
                id: strongest[:id],
                type: strongest[:type],
                name: strongest[:name],
                score: score.round(2),
                confidence: strongest[:confidence].to_f.round(2),
                reasons: build_reasons(records),
                relationship_kind: strongest[:relationship_kind],
                discovery_source: strongest[:source]
              }
            end

            def calculate_score(records)
              base = records.map { |record| record[:confidence].to_f }.max.to_f

              diversity_bonus =
                if records.map { |record| record[:source] }.uniq.length > 1
                  0.12
                else
                  0.0
                end

              relationship_bonus =
                records.any? { |record| record[:relationship_kind].present? } ? 0.08 : 0.0

              [
                base + diversity_bonus + relationship_bonus,
                1.0
              ].min * 100
            end

            def build_reasons(records)
              reasons = []

              records.each do |record|
                association = record[:association]

                if association.present?
                  reasons << "Connected through #{association.to_s.humanize.downcase}"
                end

                if record[:relationship_kind].present?
                  reasons << record[:relationship_kind].to_s.humanize
                end
              end

              reasons.presence || ["Related ecosystem entity"]
            end

            def adapter
              @adapter ||= EntityAdapter.new(entity)
            end
          end
        end
      end
    end
  end
end