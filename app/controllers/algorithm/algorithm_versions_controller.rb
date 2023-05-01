class Algorithm::AlgorithmVersionsController < ApplicationController
  before_action :set_algorithm_version, only: %i[ show edit update destroy preview]

  # GET /algorithm_versions or /algorithm_versions.json
  def index
    @algorithm_versions = Algorithms::AlgorithmVersion.all
  end

  # GET /algorithm_versions/1 or /algorithm_versions/1.json
  def show
  end

  def preview
    binding.pry
    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: "algorithm/shared/partials/preview/algorithm/main_page",
                                                 formats: [:html])}
      }
    end
  end

  # GET /algorithm_versions/new
  def new
    @algorithm_version = Algorithms::AlgorithmVersion.new
  end

  # GET /algorithm_versions/1/edit
  def edit
  end

  # POST /algorithm_versions or /algorithm_versions.json
  def create
    @algorithm_version = Algorithms::AlgorithmVersion.new(algorithm_version_params)

    respond_to do |format|
      if @algorithm_version.save
        format.html { redirect_to algorithm_version_url(@algorithm_version), notice: "Algorithm version was successfully created." }
        format.json { render :show, status: :created, location: @algorithm_version }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @algorithm_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /algorithm_versions/1 or /algorithm_versions/1.json
  def update
    respond_to do |format|
      if @algorithm_version.update(algorithm_version_params)
        format.html { redirect_to algorithm_version_url(@algorithm_version), notice: "Algorithm version was successfully updated." }
        format.json { render :show, status: :ok, location: @algorithm_version }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @algorithm_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /algorithm_versions/1 or /algorithm_versions/1.json
  def destroy
    @algorithm_version.destroy

    respond_to do |format|
      format.html { redirect_to algorithm_versions_url, notice: "Algorithm version was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_algorithm_version
      @algorithm_version = Algorithms::AlgorithmVersion.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def algorithm_version_params
      params.require(:algorithm_version).permit(:title, :solves_the_problem, :sources, :additional_information)
    end
end
