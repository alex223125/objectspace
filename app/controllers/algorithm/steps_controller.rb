class Algorithm::StepsController < ApplicationController
  before_action :set_step, only: %i[ show edit update destroy ]

  # GET /steps or /steps.json
  def index
    @steps = Step.all
  end

  # GET /steps/1 or /steps/1.json
  def show
  end

  # TODO do we use it? or we use nodes controlller?
  def substep_template

    form = SimpleForm::FormBuilder.new(
      "dynamic_step_#{Time.now.strftime("%I%M%S")}", # the scope for the inputs
      Algorithms::Nodes::Step.new,        # object wrapped by the form builder
      view_context,  # the template where the form builder can call the tag helpers on
      {}             # options
    )

      # if params[:type] == "regular_step"
      #   # path = "algorithm/shared/partials/substeps/regular_substep_fields"
      #   path = "algorithm/shared/partials/substeps/regular_substep_dynamic_form"
      #   # path = "algorithm/shared/partials/preview/algorithm/main_page"
      # elsif params[:type] == "wrapper_step"
      #   path = "algorithm/shared/partials/substeps/wrapper_substep_fields"
      # end

    # binding.pry
    if params[:type] == "regular_step"
      path = "algorithm/shared/partials/steps/regular_substep_dynamic_form"
    elsif params[:type] == "wrapper_step"
      path = "algorithm/shared/partials/steps/wrapper_substep_dynamic_form"
    elsif params[:type] == "container_step"
      path = "algorithm/shared/partials/steps/continer_substep_dynamic_form"
    end

    template = render_to_string(
          partial: path,
          layout: false,
          locals: { form: form },
          formats: [:html]
        )

        # format.json {
        #   render json: { substep_template: render_to_string(partial: path, formats: [:html])}
        # }

    respond_to do |format|
      format.json {
        render json: { substep_template: template}
      }
    end
  end

  # GET /steps/new
  def new
    @step = Step.new
  end

  # GET /steps/1/edit
  def edit
  end

  # POST /steps or /steps.json
  def create
    @step = Step.new(step_params)

    respond_to do |format|
      if @step.save
        format.html { redirect_to step_url(@step), notice: "Step was successfully created." }
        format.json { render :show, status: :created, location: @step }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /steps/1 or /steps/1.json
  def update
    respond_to do |format|
      if @step.update(step_params)
        format.html { redirect_to step_url(@step), notice: "Step was successfully updated." }
        format.json { render :show, status: :ok, location: @step }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /steps/1 or /steps/1.json
  def destroy
    @step.destroy

    respond_to do |format|
      format.html { redirect_to steps_url, notice: "Step was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_step
      @step = Step.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def step_params
      params.require(:step).permit(:title, :instruction)
    end
end
