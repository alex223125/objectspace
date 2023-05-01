class Algorithm::AlgorithmsController < ApplicationController
  before_action :set_algorithm, only: %i[ show edit update destroy ]

  # GET /algorithms or /algorithms.json
  def index
    @algorithms = Algorithms::Algorithm.all
  end

  # # GET /algorithms/1 or /algorithms/1.json
  # def show
  # end

  # GET /algorithms/new
  def new
    @algorithm = Algorithms::Algorithm.new
    @algorithm_version = @algorithm.algorithm_versions.new
    @control_structure = @algorithm_version.control_structures.new
    binding.pry
    # @step = @algorithm_version.steps.new
  end

  # GET /algorithms/1/edit
  def edit
  end

  # POST /algorithms or /algorithms.json
  def create
    binding.pry
    service = Services::Algorithms::Algorithms::Create.new(algorithm_params)
    service.call

    respond_to do |format|

      binding.pry
      if service.errors.blank?
        # format.html { redirect_to algorithm_algorithm_url(service.algorithm), notice: "Algorithm was successfully created." }
        format.html { redirect_to algorithm_algorithm_version_path(service.algorithm.default_version), notice: "Algorithm was successfully created." }

        format.json { render :show, status: :created, location: @algorithm }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @algorithm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /algorithms/1 or /algorithms/1.json
  def update
    respond_to do |format|
      if @algorithm.update(algorithm_params)
        format.html { redirect_to algorithm_url(@algorithm), notice: "Algorithm was successfully updated." }
        format.json { render :show, status: :ok, location: @algorithm }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @algorithm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /algorithms/1 or /algorithms/1.json
  def destroy
    @algorithm.destroy

    respond_to do |format|
      format.html { redirect_to algorithms_url, notice: "Algorithm was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_algorithm
      @algorithm = Algorithms::Algorithm.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def algorithm_params
      params.require(:algorithms_algorithm).permit(:title, :description, :source_page_description,

                                                   algorithm_versions_attributes: [:title, :solves_the_problem,
                                                                                   :sources, :additional_information,

                                                       control_structures_attributes: [
                                                           steps_attributes: [:position,
                                                                              :title,
                                                                              :instruction,
                                                                              :step_finish_check,
                                                                              :solves_the_problem,
                                                                              :sources,
                                                                              :additional_information,
                                                                              :_destroy,
                                                              substeps_attributes: [ :unit_id, :algorithm_id,
                                                                                     :title, :note, :position]]
                                                         ]
                                                   ])


    end
end
