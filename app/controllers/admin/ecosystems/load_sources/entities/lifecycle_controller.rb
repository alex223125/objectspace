# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities

        class LifecycleController < ApplicationController

          before_action :set_entity

          # ========================================================
          # PUBLISH
          # ========================================================

          def publish
            ::Ecosystems::LoadSources::Entity::EntityLifecycle.publish!(
              entity: @entity,
              actor: current_user
            )

            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              notice: "Entity published successfully."
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::Error => e
            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              alert: e.message
            )
          end

          # ========================================================
          # SCHEDULE
          # ========================================================

          def schedule
            publish_at =
              Time.zone.parse(
                params.require(:publish_at)
              )

            ::Ecosystems::LoadSources::Entity::EntityLifecycle.schedule_publish!(
              entity: @entity,
              publish_at: publish_at,
              actor: current_user
            )

            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              notice: "Entity publication scheduled successfully."
            )

          rescue ArgumentError,
            ActionController::ParameterMissing,
            ::Ecosystems::LoadSources::Entity::EntityLifecycle::Error => e

            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              alert: e.message
            )
          end

          # ========================================================
          # UNSCHEDULE
          # ========================================================

          def unschedule
            ::Ecosystems::LoadSources::Entity::EntityLifecycle
              .unschedule_publish!(
                entity: @entity,
                actor: current_user
              )

            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              notice: "Scheduled publication cancelled."
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::Error => e

            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              alert: e.message
            )
          end

          private

          def set_entity
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.find(
                params[:id]
              )
          end

        end

      end
    end
  end
end