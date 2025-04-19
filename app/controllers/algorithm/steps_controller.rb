class Algorithm::StepsController < ApplicationController
  include TechBreadcrumbable

  before_action :set_algorithm_version, only: %i[ show index]
  before_action :set_step, only: %i[ show ]

  # GET /steps or /steps.json
  def index
    @algorithm = @algorithm_version.algorithm
    technology_breadcrumbs(@algorithm_version, scenario: "list_of_algorithm_version_steps")
  end

  # GET /steps/1 or /steps/1.json
  def show
    binding.pry
    @algorithm = @algorithm_version.algorithm
    technology_breadcrumbs(@step)
    # if parameters[:action] = "current_step"
    #   @algorithm_versions.algorithm_tree
    # elsif parameters[:action] = "next_step"
    #
    # elsif parameters[:action] = "previous_step"
    #
    # end
  end

  # we use nodes controlller instead of this
  # def substep_template
  #
  #   form = SimpleForm::FormBuilder.new(
  #     "dynamic_step_#{Time.now.strftime("%I%M%S")}", # the scope for the inputs
  #     Algorithms::Nodes::Step.new,        # object wrapped by the form builder
  #     view_context,  # the template where the form builder can call the tag helpers on
  #     {}             # options
  #   )
  #
  #   if params[:type] == "regular_step"
  #     path = "algorithm/shared/partials/steps/regular_substep_dynamic_form"
  #   elsif params[:type] == "wrapper_step"
  #     path = "algorithm/shared/partials/steps/wrapper_substep_dynamic_form"
  #   elsif params[:type] == "container_step"
  #     path = "algorithm/shared/partials/steps/continer_substep_dynamic_form"
  #   end
  #
  #   template = render_to_string(
  #         partial: path,
  #         layout: false,
  #         locals: { form: form },
  #         formats: [:html]
  #       )
  #
  #   respond_to do |format|
  #     format.json {
  #       render json: { substep_template: template}
  #     }
  #   end
  # end

  # GET /steps/new
  # def new
  #   @step = Step.new
  # end

  # GET /steps/1/edit
  # def edit
  # end

  # POST /steps or /steps.json
  # def create
  #   @step = Step.new(step_params)
  #
  #   respond_to do |format|
  #     if @step.save
  #       format.html { redirect_to step_url(@step), notice: "Step was successfully created." }
  #       format.json { render :show, status: :created, location: @step }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @step.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /steps/1 or /steps/1.json
  # def update
  #   respond_to do |format|
  #     if @step.update(step_params)
  #       format.html { redirect_to step_url(@step), notice: "Step was successfully updated." }
  #       format.json { render :show, status: :ok, location: @step }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @step.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /steps/1 or /steps/1.json
  # def destroy
  #   @step.destroy
  #
  #   respond_to do |format|
  #     format.html { redirect_to steps_url, notice: "Step was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_step
    binding.pry
    @step = Algorithms::Nodes::Node.friendly.find(params[:id])
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    request_slug = params[:id]
    if request_slug != @step.slug
      return redirect_to algorithm_version_step_path(ownername: @step.algorithm_version.owner.ownername,
                                                     algorithm_version_id: @step.algorithm_version.slug,
                                                     id: @step.slug),
                         :status => :moved_permanently
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Model not found"
    redirect_to :root
  end

  def set_algorithm_version
    binding.pry
    @algorithm_version = Algorithms::AlgorithmVersion.friendly.find(params[:algorithm_version_id])
  end

    # Only allow a list of trusted parameters through.
    # def step_params
    #   params.require(:step).permit(:title, :instruction)
    # end
end
