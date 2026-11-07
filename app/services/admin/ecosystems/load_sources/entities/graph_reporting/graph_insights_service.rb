
# app/services/admin/ecosystems/load_sources/entities/graph_reporting/graph_insights_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module GraphReporting
          class GraphInsightsService
            Base = Admin::Ecosystems::LoadSources::Entities::EntityRelationship

            def call
              metrics = Base::GraphMetricsService.new.call
              coverage = Base::GraphCoverageService.new.call
              health = Base::GraphHealthService.new.call
              centrality = Base::GraphCentralityService.new(top: 10).call

              insights = []

              if metrics[:entity_count].zero?
                insights << {
                  type: "data_gap",
                  title: "No entities",
                  detail: "Add reviewed entity records before presenting the graph."
                }
              end

              if coverage[:coverage_percentage].to_f < 50
                insights << {
                  type: "coverage",
                  title: "Low confirmed connectivity",
                  detail: "Fewer than half of the entity records participate in confirmed relationships."
                }
              end

              unless health[:findings].empty?
                insights << {
                  type: "quality",
                  title: "Data quality requires review",
                  detail: health[:findings].join("; ")
                }
              end

              {
                insights: insights,
                highest_degree_entities: centrality[:ranked_entities],
                evidence_policy: "Insights are generated from stored records; they are not causal claims."
              }
            end
          end
        end
      end
    end
  end
end