
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ReviewAssignmentService
            def initialize(reviewers:, required_skills: [], excluded_ids: [])
              @reviewers = Array(reviewers)
              @required_skills = Array(required_skills).map(&:to_s)
              @excluded_ids = Array(excluded_ids).map(&:to_s)
            end

            def call
              eligible = reviewers.filter_map do |reviewer|
                data = normalize(reviewer)
                next if data[:id].blank?
                next if excluded_ids.include?(data[:id].to_s)

                skills = data[:skills]
                matched = required_skills & skills

                next unless (required_skills - skills).empty?

                {
                  id: data[:id],
                  name: data[:name],
                  workload: data[:workload],
                  matched_skills: matched,
                  score: matched.length * 20 - data[:workload]
                }
              end

              ranked = eligible.sort_by { |item| [-item[:score], item[:workload], item[:name].to_s] }

              {
                required_skills: required_skills,
                eligible_count: ranked.length,
                recommendations: ranked
              }
            end

            private

            attr_reader :reviewers, :required_skills, :excluded_ids

            def normalize(reviewer)
              data = reviewer.respond_to?(:to_h) ? reviewer.to_h : {}
              data = data.stringify_keys

              {
                id: data["id"],
                name: data["name"] || data["email"],
                skills: Array(data["skills"]).map(&:to_s),
                workload: [data["workload"].to_i, 0].max
              }
            end
          end
        end
      end
    end
  end
end