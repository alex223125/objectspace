# frozen_string_literal: true

require "test_helper"

class InvalidateApprovalTest < ActiveSupport::TestCase

  setup do
    @entity =
      Ecosystems::LoadSources::Entity::Entity.create!(
        name: "Test Entity",
        slug: "test-entity-#{SecureRandom.hex(4)}",
        status: "draft",
        workflow_state: "approved",
        scope: "conceptual",
        summary: "Test summary"
      )

    @entity.update!(
      publish_at: 1.hour.from_now
    )
  end

  test "returns approved entity to review" do
    Ecosystems::LoadSources::Entities::InvalidateApproval.call!(
      entity: @entity,
      actor: nil,
      reason: "Content changed after approval."
    )

    @entity.reload

    assert_equal(
      "review",
      @entity.workflow_state
    )

    assert_nil(
      @entity.publish_at
    )

    assert_nil(
      @entity.approved_at
    )

    assert_nil(
      @entity.approved_by_id
    )
  end

  test "records approval invalidated event" do
    assert_difference(
      -> {
        @entity.events.where(
          event_type: "approval_invalidated"
        ).count
      },
      1
    ) do

      Ecosystems::LoadSources::Entities::InvalidateApproval.call!(
        entity: @entity,
        actor: nil,
        reason: "Content changed after approval."
      )

    end

    event =
      @entity.events
             .where(
               event_type: "approval_invalidated"
             )
             .order(created_at: :desc)
             .first

    assert_equal(
      "Content changed after approval.",
      event.metadata["reason"]
    )
  end

end