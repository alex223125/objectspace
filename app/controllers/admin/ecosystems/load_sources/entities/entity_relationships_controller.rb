# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources

      class EntityRelationshipsController < ApplicationController

        before_action :set_entity

        # ==========================================================
        # GET /.../entities/:entity_id/relationships
        # ==========================================================

        def index
          relationships =
            @entity
              .relationships
              .active
              .includes(
                :source_entity,
                :target_entity
              )
              .ordered_by_confidence
              .limit(limit_param)

          render json: {
            entity: {
              id: @entity.id,
              name: @entity.name,
              slug: @entity.slug
            },
            relationships:
              relationships.map do |relationship|
                other =
                  relationship.other_entity(@entity)

                {
                  id: relationship.id,
                  entity_id: other&.id,
                  entity_name: other&.name,
                  entity_slug: other&.slug,
                  relationship_kind:
                    relationship.relationship_kind,
                  confidence:
                    relationship.confidence.to_f,
                  confidence_percent:
                    relationship.confidence_percent,
                  state: relationship.state,
                  direction:
                    relationship.direction_for(@entity).to_s,
                  evidence:
                    relationship.evidence_items
                }
              end
          }
        end

        # ==========================================================
        # POST /.../entities/:entity_id/relationships/discover
        # ==========================================================

        def discover
          relationships =
            ::Ecosystems::LoadSources::EntityRelationshipDiscovery
              .new(
                entity: @entity,
                limit: limit_param
              )
              .call

          render json: {
            entity_id: @entity.id,
            discovered_count: relationships.length,
            relationships:
              relationships.map(&:as_intelligence_json)
          }, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          render json: {
            error: e.message
          }, status: :unprocessable_entity
        end

        private

        def set_entity
          @entity =
            ::Ecosystems::LoadSources::Entity::Entity.find(
              params[:entity_id]
            )
        end

        def limit_param
          params.fetch(:limit, 20).to_i.clamp(1, 100)
        end

      end

    end
  end
end