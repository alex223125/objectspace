# frozen_string_literal: true

require "test_helper"

class Admin::Ecosystems::LoadSources::EntitiesControllerWorkflowTest <
  ActionDispatch::IntegrationTest

  setup do
    @entity =
      Ecosystems::LoadSources::Entity::Entity.create!(
        name: "Approved Entity",
        slug: "approved-entity-#{SecureRandom.hex(4)}",
        status: "draft",
        workflow_state: "approved",
        scope: "conceptual",
        summary: "Original summary"
      )

    @entity.update!(
      publish_at: 2.hours.from_now
    )
  end

  test "editing approved content invalidates approval and schedule" do
    patch(
      admin_ecosystems_load_sources_entity_path(@entity),
      params: {
        entity: {
          summary: "Changed summary"
        }
      }
    )

    assert_response :redirect

    @entity.reload

    assert_equal(
      "review",
      @entity.workflow_state
    )

    assert_nil(
      @entity.publish_at
    )

    assert_equal(
      "Changed summary",
      @entity.summary
    )

    assert_equal(
      "approval_invalidated",
      @entity.events.order(created_at: :desc).first.event_type
    )
  end

end