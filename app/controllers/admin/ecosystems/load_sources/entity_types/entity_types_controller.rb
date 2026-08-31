module Admin
  module Ecosystems
    module LoadSources
      module EntityTypes
        class EntityTypesController < ::AdminController

          before_action :set_entity_type,
                        only: %i[show edit update destroy]

          def index
            @entity_types = ::Ecosystems::LoadSources::EntityTypes::EntityType.includes(:parent)

            if params[:q].present?
              query = "%#{params[:q].strip}%"

              @entity_types = @entity_types.where(
                "name ILIKE :query OR slug ILIKE :query OR description ILIKE :query",
                query: query
              )
            end

            case params[:sort]
            when "name_desc"
              @entity_types = @entity_types.order(name: :desc)

            when "newest"
              @entity_types = @entity_types.order(created_at: :desc)

            when "oldest"
              @entity_types = @entity_types.order(created_at: :asc)

            else
              @entity_types = @entity_types.order(name: :asc)
            end

            if turbo_frame_request?
              render(
                partial: "results",
                locals: {
                  entity_types: @entity_types,
                  pagy: nil
                }
              )
              return
            end

            render_with_entity_templates_layout
          end

          def show

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_types/entity_types/show",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          def new
            @entity_type =
              ::Ecosystems::LoadSources::EntityTypes::EntityType.new(
                active: true
              )

            # render_with_entity_templates_layout


            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_types/entity_types/new",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          def create
            @entity_type =
              ::Ecosystems::LoadSources::EntityTypes::EntityType.new(
                entity_type_params
              )

            if @entity_type.save
              redirect_to(
                admin_ecosystems_load_sources_entity_types_entity_type_path(
                  @entity_type
                ),
                notice: "Entity type created successfully."
              )
            else
              render(
                :new,
                status: :unprocessable_entity
              )
            end
          end

          def edit
          end

          def update
            if @entity_type.update(entity_type_params)
              redirect_to(
                admin_ecosystems_load_sources_entity_types_entity_type_path(
                  @entity_type
                ),
                notice: "Entity type updated successfully."
              )
            else
              render(
                :edit,
                status: :unprocessable_entity
              )
            end
          end

          def destroy
            if @entity_type.destroy
              redirect_to(
                admin_ecosystems_load_sources_entity_types_entity_types_path,
                notice: "Entity type deleted successfully."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_types_entity_types_path,
                alert: @entity_type.errors.full_messages.to_sentence
              )
            end
          end

          private

          def set_entity_type
            @entity_type =
              ::Ecosystems::LoadSources::EntityTypes::EntityType.find(
                params[:id]
              )
          end

          def entity_type_params
            params
              .require(
                :ecosystems_load_sources_entity_types_entity_type
              )
              .permit(
                :name,
                :slug,
                :description,
                :active
              )
          end

          def render_with_entity_templates_layout
            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_types/entity_types/index",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

        end
      end
    end
  end
end
