
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class HealthCheck
            REQUIRED_WORKSPACE_METHODS = %i[
              active?
              completed?
              archived?
              complete!
              archive!
              reopen!
            ].freeze

            def initialize(workspace_class:)
              @workspace_class = workspace_class
            end

            def call
              {
                model: workspace_class.name,
                table_exists: workspace_class.table_exists?,
                associations: associations_report,
                methods: methods_report,
                columns: columns_report,
                snapshot_support: snapshot_support_report,
                errors: errors
              }
            end

            private

            attr_reader :workspace_class

            def associations_report
              %i[items research_workspace_snapshots collection_memberships].to_h do |name|
                [name, workspace_class.reflect_on_association(name).present?]
              end
            end

            def methods_report
              REQUIRED_WORKSPACE_METHODS.to_h do |name|
                [name, workspace_class.method_defined?(name)]
              end
            end

            def columns_report
              return [] unless workspace_class.table_exists?

              workspace_class.column_names.sort
            end

            def snapshot_support_report
              association = workspace_class.reflect_on_association(
                :research_workspace_snapshots
              )

              {
                association: association.present?,
                snapshot_model: association&.klass&.name
              }
            rescue NameError, ActiveRecord::ActiveRecordError => error
              {
                association: false,
                error: error.class.name
              }
            end

            def errors
              result = []

              unless workspace_class.table_exists?
                result << "Workspace table does not exist"
              end

              associations_report.each do |name, exists|
                result << "Missing association: #{name}" unless exists
              end

              methods_report.each do |name, exists|
                result << "Missing lifecycle method: #{name}" unless exists
              end

              result
            rescue ActiveRecord::ActiveRecordError => error
              ["Health check failed: #{error.class.name}"]
            end
          end
        end
      end
    end
  end
end