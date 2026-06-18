# class UnitUsageExamplesController < ApplicationController
#   before_action :set_unit_usage_example, only: %i[ show edit update destroy ]
#
#   # GET /usage_examples or /usage_examples.json
#   def index
#     # @usage_examples = UnitUsageExample.all
#
#     binding.pry
#     if params[:unit_version_id].present?
#       binding.pry
#       @unit_version = Units::UnitVersion.find_by_id(params[:unit_version_id])
#       @unit_usage_examples = @unit_version.unit.unit_usage_examples
#     end
#
#     #search (add after first layer build)
#     binding.pry
#     @pagy, @unit_usage_examples = pagy(@unit_usage_examples, page: params[:page], items: 3 )
#
#     respond_to do |format|
#       format.html
#       format.json {
#         render json: { entries: render_to_string(partial: "unit/unit_versions/partials/usage_examples_content/usage_examples_items",
#                                                  formats: [:html]),
#                        pagination: @pagy }
#       }
#     end
#
#   end
#
#
#   # def index_1
#   #
#   #   binding.pry
#   #   @improvements = Improvement.all
#   #
#   #   binding.pry
#   #   if params[:unit_version_id].present?
#   #     binding.pry
#   #     @unit_version = Units::UnitVersion.find_by_id(params[:unit_version_id])
#   #     @improvements = @unit_version.unit.improvements
#   #   end
#   #
#   #   binding.pry
#   #   if params[:query].present?
#   #     @improvements.global_search(params[:query])
#   #   end
#   #
#   #
#   #   # Improvement.global_search("a")
#   #
#   #   binding.pry
#   #   @pagy, @improvements = pagy(@improvements, page: params[:page], items: 3 )
#   #
#   #   binding.pry
#   #   respond_to do |format|
#   #     format.html
#   #     format.json {
#   #       render json: { entries: render_to_string(partial: "unit/unit_versions/partials/improvements_content/improvements_items",
#   #                                                formats: [:html]),
#   #                      pagination: @pagy }
#   #     }
#   #   end
#   # end
#
#   # GET /usage_examples/1 or /usage_examples/1.json
#   def show
#
#     # breadcrumbs
#     add_breadcrumb "Unit", unit_unit_version_path(@unit_usage_example.unit.default_version)
#     add_breadcrumb "Unit Usage Examples", unit_unit_version_path(@unit_usage_example.unit.default_version)
#     add_breadcrumb "Example", unit_usage_example_path(@unit_usage_example)
#   end
#
#   # GET /usage_examples/new
#   def new
#     if params[:unit_id].present?
#       set_unit
#     end
#     @unit_usage_example = UnitUsageExample.new
#   end
#
#   # GET /usage_examples/1/edit
#   def edit
#   end
#
#   # POST /usage_examples or /usage_examples.json
#   def create
#     binding.pry
#     @unit_usage_example = UnitUsageExample.new(unit_usage_example_params)
#
#     binding.pry
#     respond_to do |format|
#       if @unit_usage_example.save
#         format.html { redirect_to unit_usage_example_url(@unit_usage_example), notice: "Unit usage example was successfully created." }
#         format.json { render :show, status: :created, location: @unit_usage_example }
#       else
#         format.html { render :new, status: :unprocessable_entity }
#         format.json { render json: @unit_usage_example.errors, status: :unprocessable_entity }
#       end
#     end
#   end
#
#   # PATCH/PUT /usage_examples/1 or /usage_examples/1.json
#   def update
#     respond_to do |format|
#       if @unit_usage_example.update(unit_usage_example_params)
#         format.html { redirect_to unit_usage_example_url(@unit_usage_example), notice: "Unit usage example was successfully updated." }
#         format.json { render :show, status: :ok, location: @unit_usage_example }
#       else
#         format.html { render :edit, status: :unprocessable_entity }
#         format.json { render json: @unit_usage_example.errors, status: :unprocessable_entity }
#       end
#     end
#   end
#
#   # DELETE /usage_examples/1 or /usage_examples/1.json
#   def destroy
#     @unit_usage_example.destroy
#
#     respond_to do |format|
#       format.html { redirect_to unit_usage_examples_url, notice: "Unit usage example was successfully destroyed." }
#       format.json { head :no_content }
#     end
#   end
#
#   private
#
#     def set_unit
#       @unit = Units::Unit.find_by(id: params[:unit_id])
#     end
#
#     # Use callbacks to share common setup or constraints between actions.
#     def set_unit_usage_example
#       @unit_usage_example = UnitUsageExample.find(params[:id])
#     end
#
#     # Only allow a list of trusted parameters through.
#     def unit_usage_example_params
#       params.require(:unit_usage_example).permit(:title, :description, :sources, :unit_id)
#     end
# end
