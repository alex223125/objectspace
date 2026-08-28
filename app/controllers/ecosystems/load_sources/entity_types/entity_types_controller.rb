module Ecosystems
  module LoadSources
    module EntityTypes
      class EntityTypesController < ApplicationController
        before_action :set_entity_type, only: %i[show edit update destroy]

        def index
          @entity_types = EntityType
                            .includes(:parent)
                            .order(:name)
        end

        def show
        end

        def new
          @entity_type =
            ::Ecosystems::LoadSources::EntityTypes::EntityType.new(
              active: true
            )
          @parent_entity_types = EntityType.root_types.order(:name)
        end

        def edit
          @parent_entity_types = EntityType
                                   .where.not(id: @entity_type.id)
                                   .order(:name)
        end

        def create
          @entity_type = EntityType.new(entity_type_params)

          if @entity_type.save
            redirect_to entity_type_path(@entity_type),
                        notice: "Entity type was successfully created."
          else
            @parent_entity_types = EntityType.root_types.order(:name)

            render :new, status: :unprocessable_entity
          end
        end

        def update
          if @entity_type.update(entity_type_params)
            redirect_to entity_type_path(@entity_type),
                        notice: "Entity type was successfully updated."
          else
            @parent_entity_types = EntityType
                                     .where.not(id: @entity_type.id)
                                     .order(:name)

            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          if @entity_type.destroy
            redirect_to entity_types_path,
                        notice: "Entity type was successfully deleted."
          else
            redirect_to entity_types_path,
                        alert: @entity_type.errors.full_messages.to_sentence
          end
        end

        private

        def set_entity_type
          @entity_type = EntityType.find(params[:id])
        end

        def entity_type_params
          params.require(:entity_type).permit(
            :name,
            :slug,
            :description,
            :parent_id,
            :active
          )
        end
      end
    end
  end
end
