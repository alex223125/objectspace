# frozen_string_literal: true

require "test_helper"

module Ecosystems
  module LoadSources
    module Entity

      class EditorialWorkflowTest < ActiveSupport::TestCase

        setup do
          @editor =
            User.create!(
              email: "editor@example.com",
              role: "editor"
            )

          @reviewer =
            User.create!(
              email: "reviewer@example.com",
              role: "reviewer"
            )

          @admin =
            User.create!(
              email: "admin@example.com",
              role: "admin"
            )

          @entity =
            Entity.create!(
              name: "Test Entity",
              slug: "test-entity",
              entity_type: entity_type,
              entity_template: entity_template,
              scope: "conceptual",
              status: "draft",
              workflow_state: "draft"
            )
        end

        test "submit for review changes workflow state" do
          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @editor
            )

          workflow.submit_for_review!

          @entity.reload

          assert_equal(
            "review",
            @entity.workflow_state
          )

          assert_not_nil(
            @entity.review_requested_at
          )

          assert event_exists?(
                   "submitted_for_review"
                 )
        end

        test "submit for review creates initial version" do
          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @editor
            )

          assert_difference(
            -> {
              @entity.versions.count
            },
            1
          ) do
            workflow.submit_for_review!
          end
        end

        test "reviewer can approve entity" do
          submit_for_review

          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @reviewer
            )

          workflow.approve!

          @entity.reload

          assert_equal(
            "approved",
            @entity.workflow_state
          )

          assert_not_nil(
            @entity.reviewed_at
          )

          assert event_exists?(
                   "approved"
                 )
        end

        test "reviewer can reject entity" do
          submit_for_review

          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @reviewer
            )

          workflow.reject!(
            reason: "The summary needs correction."
          )

          @entity.reload

          assert_equal(
            "rejected",
            @entity.workflow_state
          )

          assert event_exists?(
                   "rejected"
                 )
        end

        test "reviewer can request changes" do
          submit_for_review

          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @reviewer
            )

          assert_difference(
            -> {
              @entity.change_requests.count
            },
            1
          ) do
            workflow.request_changes!(
              reason:
                "Please expand the historical section.",
              assigned_to: @editor
            )
          end

          @entity.reload

          assert_equal(
            "rejected",
            @entity.workflow_state
          )

          change_request =
            @entity.change_requests.last

          assert_equal(
            "open",
            change_request.status
          )

          assert_equal(
            @reviewer,
            change_request.requested_by
          )

          assert_equal(
            @editor,
            change_request.assigned_to
          )

          assert event_exists?(
                   "change_requested"
                 )
        end

        test "editor cannot approve" do
          submit_for_review

          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @editor
            )

          assert_raises(
            EditorialWorkflow::WorkflowError
          ) do
            workflow.approve!
          end
        end

        test "editor can add comment" do
          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @editor
            )

          assert_difference(
            -> {
              @entity.editorial_comments.count
            },
            1
          ) do
            workflow.add_comment!(
              body: "Please verify this information."
            )
          end

          comment =
            @entity.editorial_comments.last

          assert_equal(
            @editor,
            comment.user
          )

          assert_equal(
            "Please verify this information.",
            comment.body
          )

          assert event_exists?(
                   "comment_added"
                 )
        end

        test "admin can assign reviewer" do
          workflow =
            EditorialWorkflow.new(
              entity: @entity,
              actor: @admin
            )

          workflow.assign_reviewer!(
            reviewer: @reviewer
          )

          @entity.reload

          assert_equal(
            @reviewer,
            @entity.assigned_reviewer
          )

          assert event_exists?(
                   "reviewer_assigned"
                 )
        end

        private

        def submit_for_review
          EditorialWorkflow
            .new(
              entity: @entity,
              actor: @editor
            )
            .submit_for_review!
        end

        def event_exists?(type)
          @entity.events.where(
            event_type: type
          ).exists?
        end

        def entity_type
          @entity_type ||=
            Ecosystems::LoadSources::EntityTypes::
                EntityType.first!
        end

        def entity_template
          @entity_template ||=
            Ecosystems::LoadSources::EntityTemplates::
                EntityTemplate.first!
        end

      end

    end
  end
end