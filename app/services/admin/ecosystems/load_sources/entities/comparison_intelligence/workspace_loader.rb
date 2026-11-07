
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class WorkspaceLoader
            def initialize(context:, revision_resolver: nil)
              @context = context
              @revision_resolver = revision_resolver ||
                RevisionResolver.new
            end

            def call
              entity = load_entity
              revisions = resolve_revisions(entity)

              {
                context: context,
                entity: entity,
                revisions: revisions,
                old_version: revisions[:old_version],
                new_version: revisions[:new_version],
                available_versions: revisions[:available_versions],
                ready: revisions[:old_version].present? &&
                  revisions[:new_version].present?,
                warnings: workspace_warnings(entity, revisions)
              }
            end

            private

            attr_reader :context, :revision_resolver

            def load_entity
              return nil if context.entity_id.blank?

              model = entity_model
              return nil unless model

              model.find_by(id: context.entity_id)
            end

            def entity_model
              "::Ecosystems::LoadSources::Entity::Entity".constantize
            rescue NameError
              nil
            end

            def resolve_revisions(entity)
              return empty_revisions if entity.nil?

              revision_resolver.call(
                entity: entity,
                from_version_id: context.from_version_id,
                to_version_id: context.to_version_id
              )
            end

            def empty_revisions
              {
                old_version: nil,
                new_version: nil,
                available_versions: []
              }
            end

            def workspace_warnings(entity, revisions)
              warnings = []

              warnings << {
                code: "entity_not_selected",
                message: "Select an entity to inspect its revision history."
              } if entity.nil?

              if entity.present? &&
                revisions[:old_version].nil? &&
                revisions[:new_version].nil?
                warnings << {
                  code: "revisions_unavailable",
                  message: "No usable revision pair was found for this entity."
                }
              end

              warnings
            end
          end
        end
      end
    end
  end
end