# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities
      class PublishEntity

        def self.call!(
          entity:,
          actor: nil,
          source: "manual"
        )
          new(
            entity: entity,
            actor: actor,
            source: source
          ).call!
        end

        def initialize(
          entity:,
          actor:,
          source:
        )
          @entity = entity
          @actor = actor
          @source = source
        end

        def call!
          ActiveRecord::Base.transaction do
            lock_entity!

            validate_publishable!

            version =
              create_version!

            now =
              Time.current

            entity.update!(
              status: "published",
              workflow_state: "published",
              published_at: now,
              published_by_id: actor_id,
              publish_at: nil,
              current_version_id: version.id
            )

            create_event!(
              version: version,
              occurred_at: now
            )

            version
          end
        end

        private

        attr_reader :entity,
                    :actor,
                    :source

        def lock_entity!
          @entity =
            entity.class
                  .lock
                  .find(entity.id)
        end

        def validate_publishable!
          unless entity.workflow_state.to_s == "approved"
            raise(
              ArgumentError,
              "Entity must be approved before publishing."
            )
          end

          if entity.status.to_s == "published"
            raise(
              ArgumentError,
              "Entity is already published."
            )
          end

          unless entity.complete?
            raise(
              ArgumentError,
              "Entity is incomplete and cannot be published."
            )
          end

          if entity.publish_at.present? &&
            entity.publish_at > Time.current

            raise(
              ArgumentError,
              "Entity is scheduled for future publication."
            )
          end
        end

        def create_version!
          version_class =
            ::Ecosystems::LoadSources::Entity::EntityVersion

          version_class.create!(
            entity: entity,
            version_number: next_version_number,
            data: version_data,
            created_by_id: actor_id
          )
        end

        def version_data
          entity.attributes.slice(
            "name",
            "slug",
            "entity_type_id",
            "entity_template_id",
            "entity_template_version_id",
            "status",
            "scope",
            "summary",
            "metadata",
            "valid_from",
            "valid_until",
            "observed_at"
          )
        end

        def next_version_number
          entity.versions
                .maximum(:version_number)
                .to_i + 1
        end

        def create_event!(
          version:,
          occurred_at:
        )
          ::Ecosystems::LoadSources::Entity::EntityEvent.create!(
            entity: entity,
            entity_version: version,
            event_type: "published",
            actor_id: actor_id,
            occurred_at: occurred_at,
            metadata: {
              source: source,
              version_id: version.id
            }
          )
        end

        def actor_id
          return nil unless actor

          actor.id
        end

      end
    end
  end
end