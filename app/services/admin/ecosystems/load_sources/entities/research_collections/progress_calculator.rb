module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class ProgressCalculator
            def initialize(collection)
              @collection = collection
            end

            def call
              {
                overall: overall,
                objectives: objective_progress,
                questions: question_progress,
                milestones: milestone_progress
              }
            end

            private

            attr_reader :collection

            def overall
              components = [
                objective_progress[:percent],
                question_progress[:percent],
                milestone_progress[:percent]
              ]

              return 0 if components.empty?

              (components.sum.to_f / components.length).round
            end

            def objective_progress
              objectives = collection.objectives

              return { total: 0, completed: 0, percent: 0 } if objectives.none?

              completed = objectives.count { |objective| objective.status == "completed" }

              {
                total: objectives.count,
                completed: completed,
                percent: (completed.to_f / objectives.count * 100).round
              }
            end

            def question_progress
              questions = collection.questions

              return { total: 0, completed: 0, percent: 0 } if questions.none?

              completed = questions.count(&:answered?)

              {
                total: questions.count,
                completed: completed,
                percent: (completed.to_f / questions.count * 100).round
              }
            end

            def milestone_progress
              milestones = collection.milestones

              return { total: 0, completed: 0, percent: 0 } if milestones.none?

              completed = milestones.count { |milestone| milestone.status == "completed" }

              {
                total: milestones.count,
                completed: completed,
                percent: (completed.to_f / milestones.count * 100).round
              }
            end
          end
        end
      end
    end
  end
end
