# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EditorialQueueController < ApplicationController
          def index
            @entities =
              ::Ecosystems::LoadSources::Entity::Entity
                .where(workflow_state: "review")
                .includes(
                  :entity_type,
                  :entity_template,
                  :reviewer
                )
                .order(
                  submitted_for_review_at: :asc
                )
          end
        end
      end
    end
  end
end