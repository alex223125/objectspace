# frozen_string_literal: true

require "digest"
require "json"

module Ecosystems
  module LoadSources
    module Entity
      class EntityLifecycle

    class Error < StandardError
    end

    class InvalidState < Error
    end

    class ValidationError < Error
    end

    # ==========================================================
    # CLASS API
    # ==========================================================

    class << self

      def publish!(
        entity:,
        actor: nil,
        scheduled: false
      )
        new(
          entity: entity,
          actor: actor
        ).publish!(
          scheduled: scheduled
        )
      end

      def schedule_publish!(
        entity:,
        publish_at:,
        actor: nil
      )
        new(
          entity: entity,
          actor: actor
        ).schedule_publish!(
          publish_at: publish_at
        )
      end

      def unschedule_publish!(
        entity:,
        actor: nil
      )
        new(
          entity: entity,
          actor: actor
        ).unschedule_publish!
      end

      def archive!(
        entity:,
        actor: nil
      )
        new(
          entity: entity,
          actor: actor
        ).archive!
      end

      def restore!(
        entity:,
        actor: nil
      )
        new(
          entity: entity,
          actor: actor
        ).restore!
      end

      def deprecate!(
        entity:,
        actor: nil
      )
        new(
          entity: entity,
          actor: actor
        ).deprecate!
      end

    end

    attr_reader :entity, :actor

    def initialize(entity:, actor: nil)
      @entity = entity
      @actor = actor
    end

    # ==========================================================
    # PUBLISH
    # ==========================================================

    def publish!(scheduled: false)
      ActiveRecord::Base.transaction do
        entity.lock!

        validate_scheduled_publication! if scheduled
        validate_entity_for_publication!

        unless entity.workflow_state_approved?
          raise InvalidState,
                "Only approved entities can be published."
        end

        previous_status = entity.status
        published_at = Time.current

        version = create_publication_version!(
          published_at: published_at
        )

        entity.update!(
          status: "published",
          workflow_state: "published",
          published_at: published_at,
          published_by_id: actor_id,
          last_published_by_id: actor_id,
          publish_at: nil,
          current_version_id: version.id
        )

        record_event!(
          event_type: :published,
          entity_version: version,
          from_status: previous_status,
          to_status: "published",
          metadata: {
            scheduled: scheduled,
            version_id: version.id,
            published_at: published_at.iso8601
          }
        )

        entity
      end
    end

    # ==========================================================
    # SCHEDULE
    # ==========================================================

    def schedule_publish!(publish_at:)
      raise ArgumentError,
            "publish_at is required" if publish_at.blank?

      normalized_publish_at =
        normalize_time(publish_at)

      if normalized_publish_at <= Time.current
        raise InvalidState,
              "Publish time must be in the future."
      end

      ActiveRecord::Base.transaction do
        entity.lock!

        unless entity.can_schedule_publish?
          raise InvalidState,
                "Entity cannot be scheduled for publication."
        end

        validate_entity_for_publication!

        entity.update!(
          publish_at: normalized_publish_at
        )

        record_event!(
          event_type: :publish_scheduled,
          entity_version: entity.current_version,
          metadata: {
            publish_at: normalized_publish_at.iso8601
          }
        )

        schedule_background_job!

        entity
      end
    end

    # ==========================================================
    # UNSCHEDULE
    # ==========================================================

    def unschedule_publish!
      ActiveRecord::Base.transaction do
        entity.lock!

        unless entity.can_unschedule_publish?
          raise InvalidState,
                "Entity does not have a scheduled publication."
        end

        previous_publish_at = entity.publish_at

        entity.update!(
          publish_at: nil
        )

        record_event!(
          event_type: :publish_schedule_cancelled,
          entity_version: entity.current_version,
          metadata: {
            previous_publish_at:
              previous_publish_at&.iso8601
          }
        )

        entity
      end
    end

    # ==========================================================
    # ARCHIVE
    # ==========================================================

    def archive!
      ActiveRecord::Base.transaction do
        entity.lock!

        unless entity.status_published?
          raise InvalidState,
                "Only published entities can be archived."
        end

        previous_status = entity.status
        archived_at = Time.current

        entity.update!(
          status: "archived",
          archived_at: archived_at,
          publish_at: nil
        )

        record_event!(
          event_type: :archived,
          entity_version: entity.current_version,
          from_status: previous_status,
          to_status: "archived",
          metadata: {
            archived_at: archived_at.iso8601,
            version_id: entity.current_version_id
          }
        )

        entity
      end
    end

    # ==========================================================
    # RESTORE
    # ==========================================================

    def restore!
      ActiveRecord::Base.transaction do
        entity.lock!

        unless entity.status_archived?
          raise InvalidState,
                "Only archived entities can be restored."
        end

        unless entity.current_version.present?
          raise InvalidState,
                "Archived entity has no current version to restore."
        end

        previous_status = entity.status

        entity.update!(
          status: "published",
          workflow_state: "published",
          archived_at: nil,
          deprecated_at: nil
        )

        record_event!(
          event_type: :restored,
          entity_version: entity.current_version,
          from_status: previous_status,
          to_status: "published",
          metadata: {
            restored_at: Time.current.iso8601,
            version_id: entity.current_version_id
          }
        )

        entity
      end
    end

    # ==========================================================
    # DEPRECATE
    # ==========================================================

    def deprecate!
      ActiveRecord::Base.transaction do
        entity.lock!

        if entity.status_deprecated?
          raise InvalidState,
                "Entity is already deprecated."
        end

        unless entity.status_published? ||
               entity.status_archived?
          raise InvalidState,
                "Only published or archived entities can be deprecated."
        end

        previous_status = entity.status
        deprecated_at = Time.current

        entity.update!(
          status: "deprecated",
          deprecated_at: deprecated_at,
          publish_at: nil
        )

        record_event!(
          event_type: :deprecated,
          entity_version: entity.current_version,
          from_status: previous_status,
          to_status: "deprecated",
          metadata: {
            deprecated_at: deprecated_at.iso8601,
            version_id: entity.current_version_id
          }
        )

        entity
      end
    end

    private

    # ==========================================================
    # EVENT RECORDING
    # ==========================================================

    def record_event!(
      event_type:,
      entity_version: nil,
      from_status: nil,
      to_status: nil,
      metadata: {}
    )
      ::Ecosystems::LoadSources::Entity::EntityEvent.create!(
        entity: entity,
        entity_version: entity_version,
        event_type:
          ::Ecosystems::LoadSources::Entity::EntityEvent
            .type_for(event_type),
        from_status: from_status,
        to_status: to_status,
        actor_type: actor_type,
        actor_id: actor_id,
        metadata: metadata || {},
        snapshot: {},
        created_at: Time.current
      )
    end

    # ==========================================================
    # PUBLICATION VALIDATION
    # ==========================================================

    def validate_scheduled_publication!
      unless entity.publish_at.present?
        raise InvalidState,
              "Publication is no longer scheduled."
      end

      if entity.publish_at > Time.current
        raise InvalidState,
              "Publication time has not arrived."
      end
    end

    def validate_entity_for_publication!
      errors = entity.quality_issues.dup

      if entity.entity_template_version.blank?
        errors << "Entity template version is missing."
      end

      return true if errors.empty?

      raise ValidationError,
            "Entity cannot be published: #{errors.join(' ')}"
    end

    # ==========================================================
    # VERSION CREATION
    # ==========================================================

    def create_publication_version!(published_at:)
      version_class =
        ::Ecosystems::LoadSources::Entity::EntityVersion

      snapshot = publication_snapshot

      version_class.create!(
        entity: entity,
        version_number: next_version_number,
        status: "published",
        reason: "published",
        snapshot: snapshot,
        checksum: checksum_for(snapshot),
        published_at: published_at,
        created_by_type: actor_type,
        created_by_id: actor_id
      )
    end

    def publication_snapshot
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
      ::Ecosystems::LoadSources::Entity::EntityVersion
        .where(entity_id: entity.id)
        .maximum(:version_number)
        .to_i + 1
    end

    def checksum_for(snapshot)
      Digest::SHA256.hexdigest(
        JSON.generate(
          snapshot.sort.to_h
        )
      )
    end

    # ==========================================================
    # BACKGROUND JOB
    # ==========================================================

    def schedule_background_job!
      PublishScheduledEntityJob
        .set(wait_until: entity.publish_at)
        .perform_later(entity.id)
    end

    # ==========================================================
    # TIME
    # ==========================================================

    def normalize_time(value)
      return value if value.is_a?(Time)

      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
      raise ArgumentError,
            "Invalid publish_at value."
    end

    # ==========================================================
    # ACTOR
    # ==========================================================

    def actor_id
      return nil unless actor

      actor.respond_to?(:id) ? actor.id : actor
    end

    def actor_type
      return nil unless actor

      actor.respond_to?(:id) ? actor.class.name : "User"
    end

  end

end
end
end
