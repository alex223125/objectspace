class Unit::UnitsController < ApplicationController
  include Folderable

  before_action :set_unit, only: %i[ show edit update destroy preview view]
  before_action :set_target_folder, only: %i[ new create ]
  before_action :set_target_interface_group, only: %i[ new create ]

  # GET /units or /units.json
  def index
    @units = Units::Unit.all
  end

  # # GET /units/1 or /units/1.json
  # no show action for unit/ use unit_version
  # def show
  #   @pagy, @improvements = pagy(@unit.improvements)
  # end

  def preview
    # binding.pry
    # TODO: remove subste_addition case, we don't have this case
    # TODO -more unit preview to units folder
    # TODO - create settings object
    if params[:type] == "substep_addition"
      path = "algorithm/shared/partials/preview/unit/main_page"
    elsif params[:type] == "dpo_instruction_select" ||
          params[:type] == "interface_member_addition" ||
          params[:type] == "algorithm_form_wrapper_step_addition" ||
          params[:type] == "interface_group_form_action_addition" ||
          params[:type] == "algorithm_form_class_level_wrapper_step_addition"

      path = "shared/technologies_search/dpo_instruction_select/preview/unit"
    end



    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
                                                 formats: [:html],
                                                 locals: {unit: @unit})}
      }
    end
  end

  def view
    binding.pry
    @unit_version = @unit.default_version
    path = "unit/unit_versions/dynamic_view/main"

    respond_to do |format|
      format.json {
        render json: { view: render_to_string(partial: path,
                                                 formats: [:html])}
      }
    end
  end

  # GET /units/new
  # new unit and first unit version
  def new
    binding.pry
    @unit = Units::Unit.new
    @unit.unit_versions.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units or /units.json
  def create
    binding.pry
    # @unit = Units::Unit.new(unit_params)
    service = Services::Units::Units::Create.new(unit_params, @target_folder, current_user, @target_interface_group)
    service.call

    respond_to do |format|
      binding.pry
      if service.errors.blank?
        # format.html { redirect_to unit_unit_version_path(@unit.default_version, default_version: true), notice: "Unit was successfully created." }
        format.html { redirect_to unit_version_path(username: service.unit.ownerable.ownername,
                                                    id: service.unit.default_version.slug),
                                  notice: "Unit was successfully created." }
        format.json { render :show, status: :created, location: service.unit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1 or /units/1.json
  def update
    binding.pry
    respond_to do |format|
      if @unit.update(unit_params)
        binding.pry
        format.html { redirect_to unit_unit_version_path(@unit.default_version), notice: "Unit was successfully updated." }
        format.json { render :show, status: :ok, location: @unit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1 or /units/1.json
  def destroy
    @unit.destroy

    respond_to do |format|
      format.html { redirect_to units_url, notice: "Unit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_target_interface_group
      if params[:target_interface_group].present?
        @target_interface_group = SimpleClasses::InterfaceGroup.where(id: params[:target_interface_group]).first
      end
    end

    def set_unit
      @unit = Units::Unit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_params
      params.require(:units_unit).permit(:title, :visibility_status, :source_page_description, :tag_list,
                                         unit_versions_attributes: [:title, :solves_the_problem,
                                                        :instruction, :sources, :target_audience,
                                                                    :description,
                                                        :additional_information],
                                         unit_usage_examples_attributes: [:id, :title, :description,
                                                                          :sources, :_destroy])
      # params.require(:user).permit(:name, friends_attributes: [:id, :friend_name, :_destroy])
    end

end
