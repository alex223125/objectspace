# frozen_string_literal: true

class PublishScheduledEntityJob < ApplicationJob

  queue_as :default

  def perform(entity_id)
    entity =
      ::Ecosystems::LoadSources::Entity::Entity.find_by(
        id: entity_id
      )

    return unless entity

    return unless entity.publish_at.present?

    return if entity.publish_at > Time.current

    return unless entity.workflow_state_approved?

    ::Ecosystems::LoadSources::Entity::EntityLifecycle.publish!(
      entity: entity,
      actor: entity.approved_by,
      scheduled: true
    )

  rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::InvalidState
    # The schedule may have been cancelled or otherwise invalidated.
    #
    # This is intentional. A stale scheduled job must never publish
    # an entity after its schedule has been cancelled.
    nil
  end

end