
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class CitationQualityService
            def initialize(citations:)
              @citations = Array(citations)
            end

            def call
              results = citations.map.with_index do |citation, index|
                attributes = normalize(citation)

                issues = []
                issues << "missing_url" if attributes[:url].blank?
                issues << "missing_title" if attributes[:title].blank?
                issues << "missing_attribution" if attributes[:attribution].blank?
                issues << "missing_supporting_excerpt" if attributes[:excerpt].blank?
                issues << "unverified_source" unless attributes[:verified]

                {
                  index: index,
                  id: attributes[:id],
                  title: attributes[:title],
                  url: attributes[:url],
                  issues: issues,
                  score: score_for(issues),
                  status: issues.empty? ? "complete" : "needs_review"
                }
              end

              total = results.length
              score = total.zero? ? 0 : (results.sum { |item| item[:score] }.to_f / total).round

              {
                total: total,
                score: score,
                complete: results.count { |item| item[:status] == "complete" },
                needs_review: results.count { |item| item[:status] == "needs_review" },
                citations: results
              }
            end

            private

            attr_reader :citations

            def normalize(value)
              data = value.respond_to?(:to_h) ? value.to_h : {}
              data = data.stringify_keys

              {
                id: data["id"],
                title: data["title"].presence,
                url: data["url"].presence || data["uri"].presence,
                attribution: data["attribution"].presence || data["author"].presence,
                excerpt: data["excerpt"].presence || data["quote"].presence,
                verified: ActiveModel::Type::Boolean.new.cast(data["verified"])
              }
            end

            def score_for(issues)
              [100 - issues.length * 20, 0].max
            end
          end
        end
      end
    end
  end
end