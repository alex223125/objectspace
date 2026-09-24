# frozen_string_literal: true

class PublishScheduledEntityJob < ApplicationJob

  queue_as :default

  def perform(entity_id)
    entity =
      ::Ecosystems::LoadSources::Entity::Entity
        .find_by(id: entity_id)

    return unless entity

    return unless entity.publish_at.present?

    return if entity.publish_at > Time.current

    return unless entity.workflow_state_approved?

    ::Ecosystems::LoadSources::Entity::EntityLifecycle.publish!(
      entity: entity,
      actor: nil,
      scheduled: true
    )

  rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::InvalidState
    # Expected when a scheduled publication has been
    # cancelled or is otherwise no longer valid.
    #
    # The important behavior is that the job does NOT
    # publish the entity.
    nil
  end

end