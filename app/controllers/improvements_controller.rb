class ImprovementsController < ApplicationController
  before_action :set_improvement, only: %i[ show edit update destroy ]

  # # GET /improvements or /improvements.json
  # def index
  #   @improvements = Improvement.all
  # end

  def index

    binding.pry
    @improvements = Improvement.all

    binding.pry
    if params[:unit_version_id].present?
      binding.pry
      @unit_version = Units::UnitVersion.find_by_id(params[:unit_version_id])
      @improvements = @unit_version.unit.improvements
    end

    binding.pry
    if params[:query].present?
      @improvements.global_search(params[:query])
    end


    # Improvement.global_search("a")

    binding.pry
    @pagy, @improvements = pagy(@improvements, page: params[:page], items: 3 )

    binding.pry
    respond_to do |format|
      format.html
      format.json {
        render json: { entries: render_to_string(partial: "unit/unit_versions/partials/improvements_content/improvements_items",
                                                 formats: [:html]),
                       pagination: @pagy }
      }
    end
  end

  # GET /improvements/1 or /improvements/1.json
  def show

    # breadcrumbs
    add_breadcrumb "Unit", unit_unit_version_path(@improvement.unit.default_version)
    add_breadcrumb "Improvements", unit_unit_version_path(@improvement.unit.default_version)
    add_breadcrumb "Improvement", improvement_path(@improvement)
  end

  # GET /improvements/new
  def new
    binding.pry
    if params[:unit_id].present?
      binding.pry
      set_unit
    end
    @improvement = Improvement.new
  end

  # GET /improvements/1/edit
  def edit
  end

  # POST /improvements or /improvements.json
  def create
    binding.pry
    @improvement = Improvement.new(improvement_params)

    binding.pry
    respond_to do |format|
      binding.pry
      if @improvement.save
        # redirect_to product_path(@trademark.product, anchor: "trademarks")
        # na show improvement sdelat redirect
        # format.html { redirect_to unit_path(@improvement.unit, anchor: "improvements-tab"), notice: "Improvement was successfully submitted." }
        format.html { redirect_to improvement_url(@improvement), notice: "Improvement was successfully submitted." }
        format.json { render :show, status: :created, location: @improvement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @improvement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /improvements/1 or /improvements/1.json
  def update
    respond_to do |format|
      if @improvement.update(improvement_params)
        format.html { redirect_to improvement_url(@improvement), notice: "Improvement was successfully updated." }
        format.json { render :show, status: :ok, location: @improvement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @improvement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /improvements/1 or /improvements/1.json
  def destroy
    @improvement.destroy

    respond_to do |format|
      format.html { redirect_to improvements_url, notice: "Improvement was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_unit
      @unit = Units::Unit.find_by(id: params[:unit_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_improvement
      @improvement = Improvement.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def improvement_params
      params.require(:improvement).permit(:title, :content, :sources, :unit_id,
                                          unit_versions: [:id])
    end
end
