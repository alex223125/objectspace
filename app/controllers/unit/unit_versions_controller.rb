class Unit::UnitVersionsController < ApplicationController
  before_action :set_unit_version, only: %i[ show edit update destroy preview ]

  # GET /unit_versions or /unit_versions.json
  def index
    @unit_versions = Units::UnitVersion.all
  end

  # GET /unit_versions/1 or /unit_versions/1.json
  def show
    binding.pry
    # if params[:default_version].present?
    #
    #   binding.pry
    #   set_unit
    #   @unit_version = @unit.default_version
    # end
  end

  # GET /unit_versions/new
  def new
    binding.pry
    if params[:unit_id]
      set_unit
      @unit_version = @unit.unit_versions.new
    else
      @unit_version = Units::UnitVersion.new
    end
  end

  # GET /unit_versions/1/edit
  def edit
  end

  # POST /unit_versions or /unit_versions.json
  def create
    binding.pry
    # @unit_version = Units::UnitVersion.new(unit_version_params)
    service = Services::Units::UnitVersions::Create.new(unit_version_params)
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        binding.pry
        format.html { redirect_to unit_unit_version_path(service.unit_version), notice: "Method was successfully created." }
        # format.html { redirect_to unit_version_url(@unit_version), notice: "Unit version was successfully created." }
        format.json { render :show, status: :created, location: @unit_version }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.unit_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unit_versions/1 or /unit_versions/1.json
  def update
    respond_to do |format|
      if @unit_version.update(unit_version_params)
        format.html { redirect_to unit_version_url(@unit_version), notice: "Unit version was successfully updated." }
        format.json { render :show, status: :ok, location: @unit_version }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @unit_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_versions/1 or /unit_versions/1.json
  def destroy
    @unit_version.destroy

    respond_to do |format|
      format.html { redirect_to unit_versions_url, notice: "Unit version was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_unit
      @unit = Units::Unit.find(params[:unit_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_unit_version
      @unit_version = Units::UnitVersion.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_version_params
      params.require(:units_unit_version).permit(:title, :instruction, :solves_the_problem, :target_audience,
                                                 :sources, :additional_information, :unit_id,
                                                 unit_usage_examples_attributes: [:id, :title, :description,
                                                                                  :sources, :_destroy])
    end
end
