# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EntityIntelligenceController < ::AdminController
          before_action :set_entity, only: [:show]

          def show
            intelligence =
              ::Ecosystems::LoadSources::EntityIntelligence
                .new(@entity)
                .call

            render json: intelligence
          end

          private

          def set_entity
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.find(
                params[:entity_id]
              )
          end
        end
      end
    end
  end
end
