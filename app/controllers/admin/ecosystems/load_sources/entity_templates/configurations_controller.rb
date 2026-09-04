module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates

        class ConfigurationsController < ::AdminController
          before_action :authenticate_admin_user!

          EntityType = ::Ecosystems::LoadSources::EntityTypes::EntityType
          EntityTemplate = ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate
          EntityTemplateConfiguration =
            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateConfiguration

          def index
            load_index_data
            @configuration = EntityTemplateConfiguration.new

            render_with_entity_templates_layout
          end

          def create
            @configuration =
              EntityTemplateConfiguration.new(configuration_params)

            if @configuration.save
              redirect_to configuration_path,
                          notice: "Template configuration created successfully."
            else
              load_index_data

              flash.now[:alert] =
                @configuration.errors.full_messages.to_sentence

              render :index, status: :unprocessable_entity
            end
          end

          def update
            @configuration =
              EntityTemplateConfiguration.find(params[:id])

            if @configuration.update(configuration_params)
              redirect_to configuration_path,
                          notice: "Template configuration updated."
            else
              redirect_to configuration_path,
                          alert: @configuration.errors.full_messages.to_sentence
            end
          end

          def destroy
            configuration =
              EntityTemplateConfiguration.find(params[:id])

            configuration.destroy

            redirect_to configuration_path,
                        notice: "Template configuration removed."
          end

          private

          def configuration_params
            params.require(:entity_template_configuration).permit(
              :entity_template_id,
              :entity_type_id,
              :context_type,
              :context_id,
              :position,
              :enabled,
              settings: {}
            )
          end

          def load_index_data
            @entity_types =
              EntityType
                .order(:name)

            @templates =
              EntityTemplate
                .includes(:entity_type)
                .where(active: true)
                .order(:name)

            @configurations =
              EntityTemplateConfiguration
                .includes(
                  :entity_template,
                  :entity_type,
                  :context
                )
                .ordered

            @contexts = available_contexts
          end

          def available_contexts
            contexts = []

            if defined?(::Ecosystem)
              contexts.concat(
                ::Ecosystem.order(:name).map do |item|
                  {
                    type: "Ecosystem",
                    id: item.id,
                    name: item.name
                  }
                end
              )
            end

            if defined?(::Activity)
              contexts.concat(
                ::Activity.order(:name).map do |item|
                  {
                    type: "Activity",
                    id: item.id,
                    name: item.name
                  }
                end
              )
            end

            if defined?(::LoadSource)
              contexts.concat(
                ::LoadSource.order(:name).map do |item|
                  {
                    type: "LoadSource",
                    id: item.id,
                    name: item.name
                  }
                end
              )
            end

            contexts
          end

          def configuration_path
            admin_ecosystems_load_sources_entity_templates_configuration_path
          end



          def render_with_entity_templates_layout
            content = render_to_string(
              template: "admin/ecosystems/load_sources/entity_templates/configurations/index",
              layout: false
            )

            render(
              template: "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
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
