# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class DashboardAudit
            REQUIRED_COLUMNS = %w[id title status created_at updated_at].freeze

            OPTIONAL_ASSOCIATIONS = %i[
              items
              collection_memberships
              research_annotations
              research_evidences
              research_workspace_snapshots
            ].freeze

            def initialize(model_class)
              @model_class = model_class
            end

            def call
              {
                model: @model_class.name,
                missing_columns: REQUIRED_COLUMNS - @model_class.column_names,
                associations: association_report,
                search_columns: %w[title slug] & @model_class.column_names,
                lifecycle_statuses: lifecycle_statuses
              }
            end

            private

            def association_report
              OPTIONAL_ASSOCIATIONS.to_h do |name|
                [name, !@model_class.reflect_on_association(name).nil?]
              end
            end

            def lifecycle_statuses
              return [] unless @model_class.column_names.include?("status")

              @model_class.distinct.order(:status).pluck(:status).compact
            end
          end
        end
      end
    end
  end
end
