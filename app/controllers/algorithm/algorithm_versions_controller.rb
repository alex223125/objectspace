class Algorithm::AlgorithmVersionsController < ApplicationController
  include TechBreadcrumbable
  include Algorithm::Concerns::Subnodable
  include Memberable

  before_action :set_algorithm_version, only: %i[ show edit update destroy ]

  ALGORITHM_VERSION_FIRST_STEP = "first-step".freeze

  # GET /algorithm_versions or /algorithm_versions.json
  def index
    @algorithm_versions = Algorithms::AlgorithmVersion.all
  end

  # GET /algorithm_versions/1 or /algorithm_versions/1.json
  def show
    binding.pry
    if container_members_present?(@algorithm_version) || interface_members_present?(@algorithm_version)
      redirect_to_member(@algorithm_version)
    else
      # DOC: dispatch to view type based on amount of content
      if @algorithm_version.display_type == AlgorithmVersions::DisplayTypes[:not_defined] ||
          @algorithm_version.display_type == AlgorithmVersions::DisplayTypes[:everything_on_one_page]
        binding.pry
        # do nothing
      elsif @algorithm_version.display_type == AlgorithmVersions::DisplayTypes[:dynamic_step_by_step_window]
        binding.pry
        service = Services::Algorithms::Steps::FindFirstStep.new(@algorithm_version)
        service.call
        step = service.step

        redirect_to algorithm_version_step_path(ownername: @algorithm_version.algorithm.ownerable.ownername,
                                                algorithm_version_id: @algorithm_version.slug,
                                                id: step.slug)
      end

      technology_breadcrumbs(@algorithm_version)
      @algorithm = @algorithm_version.algorithm
    end
  end

  # GET /algorithm_versions/new
  def new
    binding.pry
    set_algorithm
    @algorithm_version = @algorithm.algorithm_versions.new
    @introduction_step = @algorithm_version.build_introduction_step

    binding.pry
    @default_algorithm_structure = @algorithm_version.control_structures.new
  end

  # GET /algorithm_versions/1/edit
  def edit
    binding.pry
    @algorithm = @algorithm_version.algorithm
    @target_folder = @algorithm.folder
  end

  # POST /algorithm_versions or /algorithm_versions.json
  def create
    set_algorithm

    binding.pry
    # DOC: 1.prepare parames
    action_type = :algorithm_version_create
    service = Services::Algorithms::Shared::Params::Create.new(params, action_type)
    new_params = service.call
    @structured_params = ActionController::Parameters.new(new_params)

    # DOC: 2.create algorithm version
    binding.pry
    service = Services::Algorithms::AlgorithmVersions::Create.new(algorithm_version_params, @algorithm)
    service.call

    @algorithm_version = service.algorithm_version
    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to algorithm_version_path(ownername: @algorithm_version.algorithm.ownerable.ownername,
                                                       id: @algorithm_version.slug),
                                  notice: "Algorithm version was successfully created." }

        format.json { render :show, status: :created, location: @algorithm_version }
      else
        binding.pry
        @algorithm_tree = service.algorithm_tree
        @root_leafe = service.root_leafe
        @control_structure = @algorithm_version.control_structures.first

        format.html { render :new, status: :unprocessable_entity,
                             assigns: { algorithm: service.algorithm,
                                        algorithm_tree: service.algorithm_tree,
                                        root_leafe: service.root_leafe} }
      end
    end
  end

  # PATCH/PUT /algorithm_versions/1 or /algorithm_versions/1.json
  def update
    # 1.prepare params
    binding.pry
    action_type = :algorithm_version_update
    service = Services::Algorithms::Shared::Params::Create.new(params, action_type)
    binding.pry
    new_params = service.call
    binding.pry
    @structured_params = ActionController::Parameters.new(new_params)


    # 2.update record
    binding.pry
    service = Services::Algorithms::AlgorithmVersions::Update.new(@algorithm_version, algorithm_version_params)
    service.call


    binding.pry
    respond_to do |format|
      if service.errors.blank?
        binding.pry
        format.html { redirect_to algorithm_version_path(ownername: service.algorithm_version.algorithm.ownerable.ownername,
                                                         id: service.algorithm_version.slug),
                                  notice: "Algorithm version was successfully updated." }


        # get "/:username/algorithms/:id", to: "algorithm/algorithm_versions#show", as: 'algorithm_version'
        format.json { render :show, status: :ok, location: service.algorithm_version }
      else
        binding.pry
        @algorithm = service.algorithm_version.algorithm
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: service.algorithm_version.errors, status: :unprocessable_entity }
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

  def set_algorithm
    binding.pry
    @algorithm = Algorithms::Algorithm.find(params[:algorithm_id])
  end


    # Use callbacks to share common setup or constraints between actions.
    def set_algorithm_version
      binding.pry
      @algorithm_version = Algorithms::AlgorithmVersion.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @algorithm_version.slug
        return redirect_to algorithm_version_path(ownername: @algorithm_version.owner.ownername,
                                                  id: @algorithm_version.slug),
                           :status => :moved_permanently
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Model not found"
      redirect_to :root
    end

    # Only allow a list of trusted parameters through.
    def algorithm_version_params
      binding.pry
      @structured_params.require(:algorithms_algorithm_version).permit(:title, :solves_the_problem,
                                                           :sources, :additional_information,
                                                           :description,

                                                           introduction_step_attributes: [
                                                               :title, :content

                                                           ],

                                                           control_structures_attributes: [

                                                             :id,
                                                             :position,
                                                             :control_structure_functional_type,
                                                             :_destroy,

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
                                                                                       :instruction, :_destroy,],
                                                               attachments_attributes: [:id, :attachable_id,
                                                                                        :attachable_type, :_destroy]]
                                                           ])
    end

end
