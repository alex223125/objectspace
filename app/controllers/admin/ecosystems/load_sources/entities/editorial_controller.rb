# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EditorialController < ApplicationController
          before_action :set_entity

          # ==========================================================
          # SUBMIT
          # ==========================================================

          def submit
            authorize!(:submit_for_review?)

            ::Ecosystems::LoadSources::Entities::EditorialWorkflow.submit!(
              entity: @entity,
              actor: current_user,
              comment: params[:comment]
            )

            redirect_to_entity(
              "Entity submitted for review."
            )
          rescue ::Ecosystems::LoadSources::Entities::EditorialWorkflow::Error,
            ArgumentError => e
            redirect_to_entity(
              e.message,
              :alert
            )
          end

          # ==========================================================
          # ASSIGN REVIEWER
          # ==========================================================

          def assign_reviewer
            authorize!(:assign_reviewer?)

            reviewer = User.find(
              params.require(:reviewer_id)
            )

            ::Ecosystems::LoadSources::Entities::EditorialWorkflow
              .assign_reviewer!(
                entity: @entity,
                reviewer: reviewer,
                actor: current_user
              )

            redirect_to_entity(
              "Reviewer assigned successfully."
            )
          rescue ActiveRecord::RecordNotFound
            redirect_to_entity(
              "Reviewer was not found.",
              :alert
            )
          rescue ::Ecosystems::LoadSources::Entities::EditorialWorkflow::Error,
            ArgumentError => e
            redirect_to_entity(
              e.message,
              :alert
            )
          end

          # ==========================================================
          # APPROVE
          # ==========================================================

          def approve
            authorize!(:approve?)

            ::Ecosystems::LoadSources::Entities::EditorialWorkflow.approve!(
              entity: @entity,
              actor: current_user,
              comment: params[:comment]
            )

            redirect_to_entity(
              "Entity approved successfully."
            )
          rescue ::Ecosystems::LoadSources::Entities::EditorialWorkflow::Error,
            ArgumentError => e
            redirect_to_entity(
              e.message,
              :alert
            )
          end

          # ==========================================================
          # REJECT
          # ==========================================================

          def reject
            authorize!(:reject?)

            ::Ecosystems::LoadSources::Entities::EditorialWorkflow.reject!(
              entity: @entity,
              actor: current_user,
              reason: params[:rejection_reason],
              comment: params[:comment]
            )

            redirect_to_entity(
              "Entity rejected."
            )
          rescue ::Ecosystems::LoadSources::Entities::EditorialWorkflow::Error,
            ArgumentError => e
            redirect_to_entity(
              e.message,
              :alert
            )
          end

          # ==========================================================
          # REQUEST CHANGES
          # ==========================================================

          def request_changes
            authorize!(:request_changes?)

            ::Ecosystems::LoadSources::Entities::EditorialWorkflow
              .request_changes!(
                entity: @entity,
                actor: current_user,
                reason: params[:reason],
                comment: params[:comment]
              )

            redirect_to_entity(
              "Changes requested from the editor."
            )
          rescue ::Ecosystems::LoadSources::Entities::EditorialWorkflow::Error,
            ArgumentError => e
            redirect_to_entity(
              e.message,
              :alert
            )
          end

          # ==========================================================
          # COMMENT
          # ==========================================================

          def comment
            authorize!(:comment?)

            ::Ecosystems::LoadSources::Entities::EditorialWorkflow.comment!(
              entity: @entity,
              actor: current_user,
              body: params[:body]
            )

            redirect_to_entity(
              "Editorial comment added."
            )
          rescue ::Ecosystems::LoadSources::Entities::EditorialWorkflow::Error,
            ArgumentError,
            ActionController::ParameterMissing => e
            redirect_to_entity(
              e.message,
              :alert
            )
          end

          private

          def set_entity
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.find(
                params[:entity_id] || params[:id]
              )
          end

          def authorize!(method)
            policy =
              ::Ecosystems::LoadSources::EntityPolicy.new(
                current_user,
                @entity
              )

            return if policy.public_send(method)

            redirect_to_entity(
              "You are not allowed to perform this editorial action.",
              :alert
            )

            throw :abort
          end

          def redirect_to_entity(message, type = :notice)
            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              type => message
            )
          end
        end
      end
    end
  end
end