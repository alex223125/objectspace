
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class IdentityCandidateService
            def call(source:, candidates:)
              source_attributes = attributes_for(source)

              Array(candidates).filter_map do |candidate|
                candidate_attributes = attributes_for(candidate)
                next if same_record?(source_attributes, candidate_attributes)

                reasons = []
                score = 0

                if same_nonblank?(
                  source_attributes["external_id"],
                  candidate_attributes["external_id"]
                )
                  score += 70
                  reasons << "Matching external identifier"
                end

                if same_nonblank?(
                  source_attributes["canonical_url"],
                  candidate_attributes["canonical_url"]
                )
                  score += 60
                  reasons << "Matching canonical URL"
                end

                source_name = normalize_name(source_attributes["name"])
                candidate_name = normalize_name(candidate_attributes["name"])

                if source_name.present? && source_name == candidate_name
                  score += 35
                  reasons << "Matching normalized name"
                end

                next if score.zero?

                {
                  candidate_id: candidate_attributes["id"],
                  name: candidate_attributes["name"],
                  score: [score, 100].min,
                  confidence: confidence_for([score, 100].min),
                  reasons: reasons,
                  decision: "requires_human_review"
                }
              end.sort_by { |candidate| -candidate[:score] }
            end

            private

            def attributes_for(record)
              record.respond_to?(:to_h) ? record.to_h.stringify_keys : {}
            end

            def same_record?(left, right)
              left["id"].present? && left["id"].to_s == right["id"].to_s
            end

            def same_nonblank?(left, right)
              left.present? && right.present? && left.to_s == right.to_s
            end

            def normalize_name(value)
              value.to_s.downcase.gsub(/[[:space:][:punct:]]+/, " ").strip
            end

            def confidence_for(score)
              case score
              when 80..100 then "high"
              when 40..79 then "medium"
              else "low"
              end
            end
          end
        end
      end
    end
  end
end