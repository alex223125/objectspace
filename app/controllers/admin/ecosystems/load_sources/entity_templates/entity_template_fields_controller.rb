module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates
        class EntityTemplateFieldsController < ::AdminController
  before_action :set_entity_template_version
  before_action :set_entity_template_field, only: %i[
    edit
    update
    destroy
  ]

  def index
    @entity_template_fields =
      @entity_template_version
        .entity_template_fields
        .ordered

    content =
      render_to_string(
        template:
          "admin/ecosystems/load_sources/entity_templates/entity_template_fields/index",
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
    @entity_template_field =
      @entity_template_version
        .entity_template_fields
        .new(
          position: @entity_template_version.entity_template_fields.maximum(:position).to_i + 1
        )

    content =
      render_to_string(
        template:
          "admin/ecosystems/load_sources/entity_templates/entity_template_fields/new",
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
    @entity_template_field =
      @entity_template_version
        .entity_template_fields
        .new(entity_template_field_params)

    if @entity_template_field.save
      redirect_to admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                    @entity_template_version
                  ),
                  notice: "Template field created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    content =
      render_to_string(
        template:
          "admin/ecosystems/load_sources/entity_templates/entity_template_fields/edit",
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

  def update
    if @entity_template_field.update(entity_template_field_params)
      redirect_to admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                    @entity_template_version
                  ),
                  notice: "Template field updated."
    else
      content =
        render_to_string(
          template:
            "admin/ecosystems/load_sources/entity_templates/entity_template_fields/edit",
          layout: false
        )

      render(
        template:
          "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
        layout: false,
        status: :unprocessable_entity,
        locals: {
          content: content
        }
      )
    end
  end

  def destroy
    @entity_template_field.destroy

    redirect_to admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice: "Template field removed."
  end

  private

  def set_entity_template_version
    @entity_template_version =
      ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion.find(
        params[:entity_template_version_id]
      )
  end

  def set_entity_template_field
    @entity_template_field =
      @entity_template_version.entity_template_fields.find(
        params[:id]
      )
  end

  def entity_template_field_params
    params
      .require(
        :ecosystems_load_sources_entity_templates_entity_template_field
      )
      .permit(
        :name,
        :slug,
        :label,
        :description,
        :field_type,
        :required,
        :multiple,
        :position,
        :active,
        settings: {}
      )
  end
        end
      end
    end
  end
end

