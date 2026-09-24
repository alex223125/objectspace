# app/services/ecosystems/load_sources/entities/editorial_queue.rb
# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities

      class EditorialQueue

        def self.review_queue
          Entity
            .where(workflow_state: "review")
            .includes(
              :reviewer,
              :entity_type,
              :entity_template
            )
            .order(
              submitted_for_review_at: :asc
            )
        end

        def self.for_reviewer(user)
          review_queue.where(
            reviewer_id: user.id
          )
        end

        def self.unassigned
          review_queue.where(
            reviewer_id: nil
          )
        end

        def self.count
          Entity.where(
            workflow_state: "review"
          ).count
        end

        def self.assigned_count(user)
          Entity.where(
            workflow_state: "review",
            reviewer_id: user.id
          ).count
        end

      end

    end
  end
end
