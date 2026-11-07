# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class WorkspaceIntelligence
            EVIDENCE_ASSOCIATION_NAMES = %i[
      evidence_references
      evidence_records
      evidence_items
      evidences
      sources
      research_evidences
    ].freeze

            WORKSPACE_ASSOCIATION_NAMES = %i[
      research_workspace
      workspace
    ].freeze

            def initialize(collection)
              @collection = collection
            end

            def call
              workspaces = workspace_records

              {
                workspace_count: workspaces.length,
                evidence_count: evidence_records(workspaces).length,
                workspaces: workspaces.map { |workspace| workspace_summary(workspace) },
                evidence_by_workspace: evidence_by_workspace(workspaces),
                coverage_percentage: coverage_percentage(workspaces)
              }
            end

            private

            attr_reader :collection

            def workspace_records
              return [] unless collection.respond_to?(:memberships)

              collection.memberships.includes(
                *workspace_includes
              ).filter_map do |membership|
                workspace_for(membership)
              end.uniq(&:id)
            rescue ActiveRecord::AssociationNotFoundError,
              ActiveRecord::StatementInvalid
              []
            end

            def workspace_includes
              collection.memberships.klass.reflect_on_all_associations
                        .select { |reflection| WORKSPACE_ASSOCIATION_NAMES.include?(reflection.name) }
                        .map(&:name)
            end

            def workspace_for(membership)
              WORKSPACE_ASSOCIATION_NAMES.each do |association|
                next unless membership.respond_to?(association)

                workspace = membership.public_send(association)
                return workspace if workspace
              end

              # Some applications use a direct workspace_id without an association.
              if membership.respond_to?(:workspace_id) &&
                defined?(ResearchWorkspace)
                return ResearchWorkspace.find_by(id: membership.workspace_id)
              end

              nil
            end

            def evidence_records(workspaces)
              workspaces.flat_map do |workspace|
                association = evidence_association_for(workspace)
                next [] unless association

                workspace.public_send(association).to_a
              rescue ActiveRecord::AssociationNotFoundError,
                ActiveRecord::StatementInvalid
                []
              end.uniq { |record| [record.class.name, record.id] }
            end

            def evidence_association_for(workspace)
              EVIDENCE_ASSOCIATION_NAMES.find do |name|
                workspace.class.reflect_on_association(name)&.collection?
              end
            end

            def evidence_by_workspace(workspaces)
              workspaces.map do |workspace|
                association = evidence_association_for(workspace)

                {
                  workspace_id: workspace.id,
                  workspace_name: display_name(workspace),
                  evidence_count: association ? workspace.public_send(association).count : 0
                }
              rescue ActiveRecord::StatementInvalid
                {
                  workspace_id: workspace.id,
                  workspace_name: display_name(workspace),
                  evidence_count: 0
                }
              end
            end

            def coverage_percentage(workspaces)
              return 0 if workspaces.empty?

              covered = evidence_by_workspace(workspaces).count do |item|
                item[:evidence_count].positive?
              end

              ((covered.to_f / workspaces.length) * 100).round
            end

            def workspace_summary(workspace)
              {
                id: workspace.id,
                name: display_name(workspace),
                status: read_attribute(workspace, :status),
                updated_at: workspace.updated_at
              }
            end

            def display_name(record)
              %i[name title].each do |attribute|
                next unless record.respond_to?(attribute)

                value = record.public_send(attribute)
                return value if value.present?
              end

              "#{record.class.name} ##{record.id}"
            end

            def read_attribute(record, attribute)
              return unless record.respond_to?(attribute)

              record.public_send(attribute)
            end
          end
        end
      end
    end
  end
end
