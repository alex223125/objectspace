class Algorithm::AlgorithmsController < ApplicationController
  include Folderable
  include Algorithm::Concerns::Subnodable

  before_action :set_algorithm, only: %i[ show edit update destroy preview view]
  before_action :set_target_folder, only: %i[ new create ]
  before_action :set_target_interface_group, only: %i[ new create ]

  # GET /algorithms or /algorithms.json
  def index
    @algorithms = Algorithms::Algorithm.all
  end

  # # GET /algorithms/1 or /algorithms/1.json
  # def show
  # end

  def preview
    binding.pry
    service = Services::Algorithms::Algorithms::PreviewSettings.new(params[:case])
    service.call

    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: service.path,
                                                 formats: [:html],
                                                 locals: {algorithm: @algorithm, scenario: service.scenario})}
      }
    end
  end

  # doc: dynamic view in the model
  def view
    binding.pry
    @algorithm_version = @algorithm.default_version
    if params[:type] = "regular"
      path = "algorithm/algorithm_versions/dynamic_view/main"
    end

    respond_to do |format|
      format.json {
        render json: { view: render_to_string(partial: path,
                                              formats: [:html])}
      }
    end
  end

  # GET /algorithms/new
  def new
    @algorithm = Algorithms::Algorithm.new
    @algorithm_version = @algorithm.algorithm_versions.new
    # @control_structure = @algorithm_version.control_structures.new
    # algorithm_default_control_structure = ControlStructures::FunctionalTypes[:following]
    # @default_algorithm_structure = @algorithm_version.control_structures.new(control_structure_functional_type: algorithm_default_control_structure)
    @default_algorithm_structure = @algorithm_version.control_structures.new

    binding.pry
    if params[:functional_type].present?
      @functional_type = Algorithms::FunctionalTypes[params[:functional_type]]
    else
      @functional_type = Algorithms::FunctionalTypes[:regular]
    end

    if params[:simple_class].present?
      @simple_class = SimpleClasses::SimpleClass.find(params[:simple_class])
    end
    # @step = @algorithm_version.steps.new
  end



  # GET /algorithms/1/edit
  def edit
  end

  # POST /algorithms or /algorithms.json
  def create

    # 1.prepare params
    action_type = :algorithm_creation
    binding.pry
    service = Services::Algorithms::Shared::Params::Create.new(params, action_type)
    binding.pry
    new_params = service.call
    binding.pry
    @params = ActionController::Parameters.new(new_params)

    # 2.create record
    target_place = @target_repository || @target_folder
    binding.pry
    service = Services::Algorithms::Algorithms::Create.new(algorithm_params, target_place,
                                                           current_user, @target_interface_group)
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
        @functional_type = @algorithm.functional_type

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

  def set_target_interface_group
    if params[:target_interface_group].present?
      @target_interface_group = SimpleClasses::InterfaceGroup.where(id: params[:target_interface_group]).first
    end
  end

    # Use callbacks to share common setup or constraints between actions.
  def set_algorithm
    @algorithm = Algorithms::Algorithm.find_by(uuid: params[:id]) || Algorithms::Algorithm.find(params[:id])
  end

  def algorithm_params
    @params.require(:algorithms_algorithm).permit(:title, :description, :source_page_description, :tag_list,
                                                  :functional_type,

                                                  algorithm_versions_attributes: [:id, :title, :solves_the_problem,
                                                                                  :sources, :additional_information,
                                                                                  :description,

                                                                                  control_structures_attributes: [

                                                                                    :id,
                                                                                    :position,
                                                                                    :control_structure_functional_type,

                                                                                    subnodes_attributes: [
                                                                                      :technologiable_type,
                                                                                      :technologiable_id,

                                                                                      :id,

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
                                                                                      :description,

                                                                                      :_destroy,
                                                                                      recursive_nested_substeps_attr,
                                                                                      conditions_attributes: [:id, :title,
                                                                                                              :instruction, :_destroy],
                                                                                      attachments_attributes: [:id, :attachable_id,
                                                                                                               :attachable_type, :_destroy] ]
                                                                                  ]
                                                  ])

  end

end
