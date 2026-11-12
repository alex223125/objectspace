# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities

        class RelationshipsController < Admin::Ecosystems::LoadSources::EntitiesController

          before_action :load_entity

          # GET
          #
          # Returns the current relationship intelligence
          # for one entity.
          #
          # /admin/ecosystems/load_sources/entities/:entity_id/relationships
          #
          def index
            payload =
              intelligence_service.call

            respond_to do |format|
              format.html do
                @intelligence = payload

                render(
                  "admin/ecosystems/load_sources/entities/relationships/index"
                )
              end

              format.json do
                render json:
                         Ecosystems::LoadSources::Entity::
                             RelationshipIntelligencePresenter
                           .new(payload)
                           .as_json
              end
            end
          end

          # POST
          #
          # Runs deterministic relationship discovery.
          #
          # /admin/ecosystems/load_sources/entities/:entity_id/relationships/discover
          #
          def discover
            result =
              Ecosystems::LoadSources::Entity::
                  RelationshipDiscoveryService
                .new(@entity)
                .call

            respond_to do |format|
              format.html do
                redirect_to(
                  admin_ecosystems_load_sources_entity_relationships_path(
                    @entity
                  ),
                  notice:
                    "#{result[:discovered]} relationship signals discovered."
                )
              end

              format.json do
                render json: result
              end
            end
          end

          private

          def load_entity
            @entity =
              Ecosystems::LoadSources::Entity::Entity
                .find(params[:entity_id])
          end

          def intelligence_service
            Ecosystems::LoadSources::Entity::
                RelationshipIntelligenceService
              .new(
                @entity,
                limit: params.fetch(:limit, 30)
              )
          end

        end

      end
    end
  end
end