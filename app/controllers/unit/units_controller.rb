class Unit::UnitsController < ApplicationController
  before_action :set_unit, only: %i[ show edit update destroy ]

  # GET /units or /units.json
  def index
    @units = Units::Unit.all
  end

  # # GET /units/1 or /units/1.json
  # no show action for unit/ use unit_version
  # def show
  #   @pagy, @improvements = pagy(@unit.improvements)
  # end

  # GET /units/new
  # new unit and first unit version
  def new
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
    service = Services::Units::Units::Create.new(unit_params)
    service.call

    respond_to do |format|
      binding.pry
      if service.errors.blank?
        # format.html { redirect_to unit_unit_version_path(@unit.default_version, default_version: true), notice: "Unit was successfully created." }
        format.html { redirect_to unit_unit_version_path(service.unit.default_version), notice: "Unit was successfully created." }
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
    def set_unit
      @unit = Units::Unit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_params
      params.require(:units_unit).permit(:title, :visibility_status, :source_page_description,
                                         unit_versions_attributes: [:title, :solves_the_problem,
                                                        :instruction, :sources, :target_audience,
                                                        :additional_information],
                                         unit_usage_examples_attributes: [:id, :title, :description,
                                                                          :sources, :_destroy])
      # params.require(:user).permit(:name, friends_attributes: [:id, :friend_name, :_destroy])
    end
end
