# test/services/ecosystems/load_sources/entities/editorial_workflow_test.rb

require "test_helper"

module Ecosystems
  module LoadSources
    module Entities

      class EditorialWorkflowTest < ActiveSupport::TestCase

        setup do
          @user =
            User.create!(
              name: "Editorial User",
              email: "editorial@example.com",
              username: "editorial_user",
              password: "Password123!",
              tos_agreement: true
            )

          @reviewer =
            User.create!(
              name: "Reviewer",
              email: "reviewer@example.com",
              username: "reviewer_user",
              password: "Password123!",
              tos_agreement: true
            )

          @entity =
            create_entity

          @version =
            create_version
        end

        test "submit for review changes workflow state and creates event" do
          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @user
            )

          workflow.submit_for_review!(
            comment: "Ready for editorial review."
          )

          @entity.reload

          assert_equal(
            "review",
            @entity.workflow_state
          )

          assert_equal(
            @user.id,
            @entity.submitted_by_id
          )

          assert @entity.submitted_for_review_at.present?

          event =
            @entity.events.order(:id).last

          assert_equal(
            "submitted_for_review",
            event.event_type
          )

          assert_equal(
            @version.id,
            event.entity_version_id
          )
        end

        test "reviewer can be assigned" do
          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @user
            )

          @entity.update!(
            workflow_state: "review"
          )

          workflow.assign_reviewer!(
            reviewer: @reviewer
          )

          @entity.reload

          assert_equal(
            @reviewer.id,
            @entity.reviewer_id
          )

          assert @entity.reviewer_assigned_at.present?

          event =
            @entity.events.order(:id).last

          assert_equal(
            "reviewer_assigned",
            event.event_type
          )
        end

        test "approve changes workflow state" do
          @entity.update!(
            workflow_state: "review"
          )

          EditorialWorkflow.new(
            entity: @entity,
            actor: @reviewer
          ).approve!(
            comment: "Looks good."
          )

          @entity.reload

          assert_equal(
            "approved",
            @entity.workflow_state
          )

          assert_equal(
            @reviewer.id,
            @entity.approved_by_id
          )

          event =
            @entity.events.order(:id).last

          assert_equal(
            "approved",
            event.event_type
          )
        end

        test "reject requires a reason" do
          @entity.update!(
            workflow_state: "review"
          )

          assert_raises(
            EditorialWorkflow::ValidationError
          ) do
            EditorialWorkflow.new(
              entity: @entity,
              actor: @reviewer
            ).reject!(
              reason: ""
            )
          end
        end

        test "request changes records a change request" do
          @entity.update!(
            workflow_state: "review"
          )

          EditorialWorkflow.new(
            entity: @entity,
            actor: @reviewer
          ).request_changes!(
            reason: "Please expand the summary."
          )

          @entity.reload

          assert_equal(
            "rejected",
            @entity.workflow_state
          )

          assert_equal(
            "Please expand the summary.",
            @entity.change_request_reason
          )

          assert @entity.change_requested_at.present?

          event =
            @entity.events.order(:id).last

          assert_equal(
            "change_requested",
            event.event_type
          )
        end

        test "comment creates an editorial comment and event" do
          EditorialWorkflow.new(
            entity: @entity,
            actor: @user
          ).comment!(
            body: "This needs another source."
          )

          comment =
            @entity.editorial_comments.order(:id).last

          assert_equal(
            "This needs another source.",
            comment.body
          )

          assert_equal(
            @user.id,
            comment.author_id
          )

          event =
            @entity.events.order(:id).last

          assert_equal(
            "comment_added",
            event.event_type
          )
        end

        private

        def create_entity
          Ecosystems::LoadSources::Entity::Entity.create!(
            name: "Test Entity",
            slug: "test-entity-#{SecureRandom.hex(4)}",
            entity_type: entity_type,
            entity_template: entity_template,
            scope: "conceptual",
            status: "draft",
            workflow_state: "draft",
            summary: "Test summary."
          )
        end

        def create_version
          Ecosystems::LoadSources::Entity::EntityVersion.create!(
            entity: @entity,
            version_number: 1,
            data: {
              "name" => @entity.name,
              "slug" => @entity.slug,
              "summary" => @entity.summary
            },
            created_by_id: @user.id
          )
        end

        def entity_type
          Ecosystems::LoadSources::EntityTypes::EntityType.first ||
            raise(
              "Create an EntityType fixture/factory before running this test."
            )
        end

        def entity_template
          Ecosystems::LoadSources::EntityTemplates::EntityTemplate.first ||
            raise(
              "Create an EntityTemplate fixture/factory before running this test."
            )
        end

      end

    end
  end
end
