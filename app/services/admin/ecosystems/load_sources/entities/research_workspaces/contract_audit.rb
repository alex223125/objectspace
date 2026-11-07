
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class ContractAudit
            Result = Struct.new(
              :model,
              :table,
              :columns,
              :associations,
              :methods,
              :errors,
              keyword_init: true
            ) do
              def valid?
                errors.empty?
              end
            end

            MODELS = {
              workspace:
                "Ecosystems::LoadSources::Entity::ResearchWorkspace::ResearchWorkspace",
              item:
                "Ecosystems::LoadSources::Entity::ResearchWorkspace::ResearchWorkspaceItem",
              evidence:
                "Ecosystems::LoadSources::Entity::ResearchWorkspace::ResearchEvidence",
              annotation:
                "Ecosystems::LoadSources::Entity::ResearchWorkspace::ResearchAnnotation",
              snapshot:
                "Ecosystems::LoadSources::Entity::ResearchWorkspace::ResearchWorkspaceSnapshot"
            }.freeze

            EXPECTED_ASSOCIATIONS = {
              workspace: %i[items snapshots],
              item: %i[],
              evidence: %i[],
              annotation: %i[],
              snapshot: %i[]
            }.freeze

            EXPECTED_WORKSPACE_METHODS = %i[
              active?
              completed?
              archived?
              complete!
              reopen!
            ].freeze

            def self.call
              new.call
            end

            def call
              MODELS.each_with_object({}) do |(key, name), results|
                results[key] = inspect_model(key, name)
              end
            end

            private

            def inspect_model(key, name)
              errors = []

              begin
                model = name.constantize
              rescue NameError => e
                return Result.new(
                  model: name,
                  table: nil,
                  columns: [],
                  associations: [],
                  methods: [],
                  errors: ["Model could not be loaded: #{e.message}"]
                )
              end

              associations =
                model.reflect_on_all_associations.map(&:name)

              columns = model.column_names.sort

              missing_associations =
                EXPECTED_ASSOCIATIONS.fetch(key, []) - associations

              if missing_associations.any?
                errors << "Missing associations: " \
                  "#{missing_associations.join(', ')}"
              end

              methods =
                if key == :workspace
                  EXPECTED_WORKSPACE_METHODS.select do |method_name|
                    model.method_defined?(method_name)
                  end
                else
                  []
                end

              if key == :workspace
                missing_methods =
                  EXPECTED_WORKSPACE_METHODS - methods

                if missing_methods.any?
                  errors << "Missing lifecycle methods: " \
                    "#{missing_methods.join(', ')}"
                end
              end

              Result.new(
                model: name,
                table: model.table_name,
                columns: columns,
                associations: associations,
                methods: methods,
                errors: errors
              )
            rescue StandardError => e
              Result.new(
                model: name,
                table: nil,
                columns: [],
                associations: [],
                methods: [],
                errors: ["Inspection failed: #{e.class}: #{e.message}"]
              )
            end
          end
        end
      end
    end
  end
end