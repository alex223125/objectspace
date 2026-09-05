module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates
        class EntityTemplatesController < ::AdminController
  before_action :set_entity_template, only: %i[show edit update destroy]
  def index
    @entity_types =
      ::Ecosystems::LoadSources::EntityTypes::EntityType
        .where(active: true)
        .order(:name)

    @query = params[:q].to_s.strip
    @entity_type_id = params[:entity_type_id].presence
    @status = params[:status].presence
    @sort = params[:sort].presence || "name_asc"

    @entity_templates =
      ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate
        .includes(:entity_type, :versions)

    if @query.present?
      @entity_templates = @entity_templates.where(
        "name ILIKE :q OR slug ILIKE :q OR description ILIKE :q",
        q: "%#{@query}%"
      )
    end

    if @entity_type_id.present?
      @entity_templates =
        @entity_templates.where(entity_type_id: @entity_type_id)
    end

    case @status
    when "active"
      @entity_templates = @entity_templates.where(active: true)
    when "inactive"
      @entity_templates = @entity_templates.where(active: false)
    end

    @entity_templates =
      case @sort
      when "name_desc"
        @entity_templates.order(name: :desc)
      when "newest"
        @entity_templates.order(created_at: :desc)
      when "oldest"
        @entity_templates.order(created_at: :asc)
      when "updated"
        @entity_templates.order(updated_at: :desc)
      else
        @entity_templates.order(name: :asc)
      end

    @entity_templates = @entity_templates.limit(12)

    render_with_entity_templates_layout
  end

  def show
    content = render_to_string(
      template: "admin/ecosystems/load_sources/entity_templates/entity_templates/show",
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

  def new
    @entity_template =
      ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate.new(
        active: true
      )

    load_form_data

    content = render_to_string(
      template: "admin/ecosystems/load_sources/entity_templates/entity_templates/new",
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

  # def create
  #   @entity_template =
  #     ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate.new(
  #       entity_template_params
  #     )
  #
  #   if @entity_template.save
  #     redirect_to(
  #       admin_ecosystems_load_sources_entity_templates_entity_template_path(@entity_template),
  #       notice: "Entity template was successfully created.",
  #       status: :see_other
  #     )
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  def create
    @entity_template = ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate.new(entity_template_params)

    if @entity_template.save
      redirect_to(
        admin_ecosystems_load_sources_entity_templates_entity_template_path(@entity_template),
        notice: "Entity template created successfully."
      )
    else
      @entity_types = ::Ecosystems::LoadSources::EntityTypes::EntityType.where(active: true).order(:name)

      render :new, status: :unprocessable_entity
    end
  end



  def edit
    load_form_data
  end

  def update
    if @entity_template.update(entity_template_params)
      redirect_to admin_ecosystems_load_sources_entity_template_path(@entity_template),
                  notice: "Entity template updated successfully."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @entity_template.destroy
      redirect_to admin_ecosystems_load_sources_entity_templates_path,
                  notice: "Entity template deleted successfully."
    else
      redirect_to admin_ecosystems_load_sources_entity_template_path(@entity_template),
                  alert: @entity_template.errors.full_messages.to_sentence
    end
  end

  private

  def set_entity_template
    @entity_template =
      ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate
        .includes(:entity_type, :versions)
        .find(params[:id])
  end

  def load_form_data
    @entity_types =
      ::Ecosystems::LoadSources::EntityTypes::EntityType
        .active
        .order(:name)
  end

  def entity_template_params
    params
      .require(:ecosystems_load_sources_entity_templates_entity_template)
      .permit(
        :name,
        :slug,
        :description,
        :entity_type_id,
        :active
      )
  end

  def render_with_entity_templates_layout
    content = render_to_string(
      template: "admin/ecosystems/load_sources/entity_templates/entity_templates/index",
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



