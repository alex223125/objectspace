## SNAPSHOT WIT OLD VERSION OF STRONG PARAMS BEFORE 'NODES' UPDATE

class Algorithm::AlgorithmsController < ApplicationController
  include Placeable

  before_action :set_algorithm, only: %i[ show edit update destroy preview ]
  before_action :set_target_place, only: %i[ new create ]

  # GET /algorithms or /algorithms.json
  def index
    @algorithms = Algorithms::Algorithm.all
  end

  # # GET /algorithms/1 or /algorithms/1.json
  # def show
  # end

  def preview
    binding.pry
    if params[:type] == "substep_addition"
      path = "algorithm/shared/partials/preview/algorithm/main_page"
    elsif params[:type] == "dpo_instruction_select" ||
          params[:type] == "interface_member_addition" ||
          params[:type] == "algorithm_form_wrapper_step_addition"
      path = "shared/technologies_search/dpo_instruction_select/preview/algorithm"
    end

    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
                                                 formats: [:html])}
      }
    end
  end

  # GET /algorithms/new
  def new
    @algorithm = Algorithms::Algorithm.new
    @algorithm_version = @algorithm.algorithm_versions.new
    # @control_structure = @algorithm_version.control_structures.new
    algorithm_default_control_structure = ControlStructures::FunctionalTypes[:following]
    binding.pry
    @default_algorithm_structure = @algorithm_version.control_structures.new(control_structure_functional_type: algorithm_default_control_structure)
    # @step = @algorithm_version.steps.new
  end

  # GET /algorithms/1/edit
  def edit
  end

  # POST /algorithms or /algorithms.json
  def create
    binding.pry
    service = Services::Algorithms::Algorithms::Params::Create.new(params)
    binding.pry
    new_params = service.call

    binding.pry
    @params = ActionController::Parameters.new(new_params)

    # params_for_dynamic_steps = dynamic_strong_params_for_dyn_steps(dynamic_steps_params)
    binding.pry
    service = Services::Algorithms::Algorithms::Create.new(algorithm_params, @target_folder, current_user)

    binding.pry
    service.call


    respond_to do |format|

      binding.pry
      if service.errors.blank?

        binding.pry
        # format.html { redirect_to algorithm_algorithm_url(service.algorithm), notice: "Algorithm was successfully created." }
        format.html { redirect_to algorithm_version_path(ownername: service.algorithm.ownerable.ownername,
                                                         id: service.algorithm.default_version.slug),
                                  notice: "Algorithm was successfully created." }
        format.json { render :show, status: :created, location: @algorithm }
      else
        binding.pry
        @algorithm = service.algorithm
        @control_structure = @algorithm.algorithm_versions.first.control_structures.first

        format.html { render :new, status: :unprocessable_entity}
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
      @params.require(:algorithms_algorithm).permit(:title, :description, :source_page_description, :tag_list,

                                                   algorithm_versions_attributes: [:title, :solves_the_problem,
                                                                                   :sources, :additional_information,

                                                       control_structures_attributes: [

                                                           :control_structure_functional_type,
                                                           steps_attributes: [
                                                                             :technologiable_type,
                                                                             :technologiable_id,

                                                                              :position,
                                                                              :type,
                                                                              :title,
                                                                              :instruction,
                                                                              :step_finish_check,
                                                                              :solves_the_problem,
                                                                              :sources,
                                                                              :additional_information,

                                                                              :step_functional_type,
                                                                              :control_structure_functional_type,

                                                                              :note,
                                                                              :_destroy, substeps_attributes]
                                                         ]
                                                   ])


    end


  def set_target_folder
    binding.pry
    @target_folder = Folder.find(params[:target_folder])
  end

  def substeps_attributes
    {substeps_attributes: [:technologiable_type,
                           :technologiable_id,

                           :position,
                           :type,
                           :title,
                           :instruction,
                           :step_finish_check,
                           :solves_the_problem,
                           :sources,
                           :additional_information,

                           :step_functional_type,
                           :control_structure_functional_type,

                           :note,
                           :_destroy, recursive_nested_substeps_attr]}
  end

  def recursive_nested_substeps_attr
    build_recursive_params(
      recursive_key: 'substeps_attributes',
      parameters: @params,
      permitted_attributes: [:technologiable_type,
                             :technologiable_id,

                             :position,
                             :type,
                             :title,
                             :instruction,
                             :step_finish_check,
                             :solves_the_problem,
                             :sources,
                             :additional_information,

                             :step_functional_type,
                             :control_structure_functional_type,

                             :note,
                             :_destroy]
    )
  end

end
