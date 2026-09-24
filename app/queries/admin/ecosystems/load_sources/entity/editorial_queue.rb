# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EditorialQueue

        def self.call(
          reviewer: nil,
          unassigned: false
        )
          scope =
            Entity
              .where(workflow_state: "review")
              .includes(
                :entity_type,
                :entity_template,
                :assigned_reviewer
              )
              .order(
                review_requested_at: :asc,
                created_at: :asc
              )

          if reviewer
            scope =
              scope.where(
                assigned_reviewer_id: reviewer.id
              )
          elsif unassigned
            scope =
              scope.where(
                assigned_reviewer_id: nil
              )
          end

          scope
        end

      end

    end
  end
end