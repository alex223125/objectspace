# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class WorkspaceQualityReport
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              {
                items: item_metrics,
                research: EvidenceQualitySummary.new(@workspace).call
              }
            end

            private

            def item_metrics
              reflection = @workspace.class.reflect_on_association(:items)

              unless reflection
                return {
                  available: false,
                  total: 0,
                  completed: nil,
                  percentage: nil
                }
              end

              relation = @workspace.items
              columns = relation.klass.column_names
              total = relation.count

              completed =
                if columns.include?("status")
                  relation.where(status: "completed").count
                elsif columns.include?("completed")
                  relation.where(completed: true).count
                end

              percentage =
                if completed.nil?
                  nil
                elsif total.zero?
                  0
                else
                  (completed.to_f / total * 100).round
                end

              {
                available: true,
                total: total,
                completed: completed,
                percentage: percentage
              }
            end
          end
        end
      end
    end
  end
end
