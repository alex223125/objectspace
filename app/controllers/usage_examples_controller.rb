class UsageExamplesController < ApplicationController
  before_action :set_usage_example, only: %i[ show edit update destroy ]

  # GET /usage_examples or /usage_examples.json
  def index
    # @usage_examples = UnitUsageExample.all

    binding.pry
    if params[:unit_version_id].present?
      binding.pry
      @unit_version = Units::UnitVersion.find_by_id(params[:unit_version_id])
      @usage_examples = @unit_version.usage_examples
    end

    #search (add after first layer build)
    binding.pry
    @pagy, @usage_examples = pagy(@usage_examples, page: params[:page], items: 3 )

    respond_to do |format|
      format.html
      format.json {
        render json: { entries: render_to_string(partial: "unit/unit_versions/partials/usage_examples_content/usage_examples_items",
          formats: [:html]),
          pagination: @pagy }
      }
    end

  end

  def preview_index
    if params[:technology_type] == "unit_version"
      unit_version = Units::UnitVersion.find_by(uuid: params[:technology_uuid])
      @usage_examples = unit_version.usage_examples
    end
    @pagy, @usage_examples = pagy(@usage_examples, page: params[:page], items: 3 )
    respond_to do |format|
      format.json {
        render json: { entries: render_to_string(partial: "usage_examples/preview_index/index",
                                                 formats: [:html],
                                                 locals: {usage_examples: @usage_examples}) }
      }
    end
  end

  # GET /usage_examples/1 or /usage_examples/1.json
  def show
    # breadcrumbs
    add_breadcrumb "Unit", unit_unit_version_path(@usage_example.unit.default_version)
    add_breadcrumb "Usage Examples", unit_unit_version_path(@usage_example.unit.default_version)
    add_breadcrumb "Example", unit_usage_example_path(@usage_example)
  end

  # GET /usage_examples/new
  def new
    if params[:unit_id].present?
      set_unit
    end
    @usage_example = UsageExample.new
  end

  # GET /usage_examples/1/edit
  def edit
  end

  # POST /usage_examples or /usage_examples.json
  def create
    @usage_example = UsageExample.new(usage_example_params)

    respond_to do |format|
      if @usage_example.save
        format.html { redirect_to usage_example_url(@usage_example), notice: "Usage example was successfully created." }
        format.json { render :show, status: :created, location: @usage_example }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @usage_example.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usage_examples/1 or /usage_examples/1.json
  def update
    respond_to do |format|
      if @usage_example.update(usage_example_params)
        format.html { redirect_to usage_example_url(@usage_example), notice: "Usage example was successfully updated." }
        format.json { render :show, status: :ok, location: @usage_example }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @usage_example.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usage_examples/1 or /usage_examples/1.json
  def destroy
    @usage_example.destroy

    respond_to do |format|
      format.html { redirect_to usage_examples_url, notice: "Usage example was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_unit
    @unit = Units::Unit.find_by(id: params[:unit_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_usage_example
    @usage_example = UsageExample.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def usage_example_params
    params.fetch(:usage_example, {})
  end
end
