# frozen_string_literal: true

require "test_helper"

class ScheduledPublishTest < ActiveSupport::TestCase

  setup do
    @entity =
      Ecosystems::LoadSources::Entity::Entity.create!(
        name: "Scheduled Entity",
        slug: "scheduled-entity-#{SecureRandom.hex(4)}",
        status: "draft",
        workflow_state: "approved",
        scope: "conceptual",
        summary: "Scheduled entity"
      )
  end

  test "schedules approved entity" do
    publish_at =
      1.hour.from_now

    Ecosystems::LoadSources::Entities::ScheduleEntityPublish.call!(
      entity: @entity,
      actor: nil,
      publish_at: publish_at
    )

    @entity.reload

    assert_in_delta(
      publish_at.to_f,
      @entity.publish_at.to_f,
      2.seconds
    )

    assert_equal(
      "approved",
      @entity.workflow_state
    )

    assert_equal(
      "publish_scheduled",
      @entity.events.order(created_at: :desc).first.event_type
    )
  end

  test "publishes scheduled entity" do
    @entity.update!(
      publish_at: 1.minute.ago
    )

    version =
      Ecosystems::LoadSources::Entities::PublishEntity.call!(
        entity: @entity,
        actor: nil,
        source: "scheduled_publish"
      )

    @entity.reload

    assert_equal(
      "published",
      @entity.status
    )

    assert_equal(
      "published",
      @entity.workflow_state
    )

    assert_not_nil(
      @entity.published_at
    )

    assert_equal(
      version.id,
      @entity.current_version_id
    )

    event =
      @entity.events.order(created_at: :desc).first

    assert_equal(
      "published",
      event.event_type
    )

    assert_equal(
      "scheduled_publish",
      event.metadata["source"]
    )
  end

end