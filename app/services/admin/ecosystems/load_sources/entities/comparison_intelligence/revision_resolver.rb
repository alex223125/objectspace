
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class RevisionResolver
            def initialize(version_model: nil)
              @version_model = version_model
            end

            def call(entity:, from_version_id: nil, to_version_id: nil)
              scope = version_scope(entity)
              versions = scope.to_a

              ordered = versions.sort_by do |version|
                [
                  version.respond_to?(:version_number) ?
                    version.version_number.to_i : 0,
                  version.respond_to?(:created_at) ?
                    (version.created_at&.to_f || 0) : 0,
                  version.id.to_s
                ]
              end

              old_version = find_requested(scope, from_version_id)
              new_version = find_requested(scope, to_version_id)

              if from_version_id.blank? && to_version_id.blank?
                old_version, new_version = ordered.last(2)
              elsif old_version.nil? && new_version.present?
                old_version = ordered.select do |version|
                  version.id.to_s != new_version.id.to_s
                end.last
              elsif new_version.nil? && old_version.present?
                new_version = ordered.find do |version|
                  version.id.to_s != old_version.id.to_s
                end
              end

              {
                old_version: old_version,
                new_version: new_version,
                available_versions: ordered.reverse
              }
            end

            private

            attr_reader :version_model

            def version_scope(entity)
              model = version_model || default_version_model
              raise NameError, "EntityVersion model is unavailable" unless model

              model.where(entity_id: entity.id).order(:version_number)
            end

            def default_version_model
              "::Ecosystems::LoadSources::Entity::EntityVersion".constantize
            rescue NameError
              nil
            end

            def find_requested(scope, id)
              return nil if id.blank?

              scope.find_by(id: id)
            end
          end
        end
      end
    end
  end
end