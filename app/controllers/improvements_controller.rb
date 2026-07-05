class ImprovementsController < ApplicationController
  include TechBreadcrumbable
  include Commentable

  before_action :set_improvement, only: %i[ show edit update destroy ]

  def index
    binding.pry
    form = Improvements::TechnologyRelatedImprovementsSearchFrom.new(search_params)

    binding.pry
    form.submit

    binding.pry
    @pagy, @improvements = pagy(form.improvements, page: form.page, items: form.items_per_page )

    binding.pry
    respond_to do |format|
      format.html
      format.json {
        render json: { entries: render_to_string(partial: "technologies/improvements_content/improvements_items",
                                                 formats: [:html]),
                       pagination: @pagy }
      }
    end
  end


  # GET /improvements/1 or /improvements/1.json
  def show
    technology_breadcrumbs(@improvement)
  end

  # GET /improvements/new
  def new
    binding.pry
    set_improvable
    @improvement = Improvements::Improvement.new
  end

  # GET /improvements/1/edit
  def edit
    @unit = @improvement.unit
  end

  # POST /improvements or /improvements.json
  def create
    binding.pry
    service = Services::Improvements::Improvements::Create.new(improvement_params, current_user, current_user)

    binding.pry
    service.call

    binding.pry
    respond_to do |format|
      binding.pry
      if service.errors.blank?
        binding.pry
        format.html { redirect_to improvement_show_path(technology_name: service.improvement.improvable.slug,
                                                   id: service.improvement.slug),
                                  notice: "Improvement was successfully submitted." }
      else
        binding.pry
        format.html { render :new, status: :unprocessable_entity, assigns: { improvement: service.improvement,
                                                                             permission: service.permission} }
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

    def search_params
      params.require(:improvements_search).permit(:tech_id, :tech_type, :page, :query, :status, :sort_by, :tech_version)
    end

    def set_improvable
      binding.pry
      if params[:article_id].present?
        @article = Articles::Article.find_by(uuid: params[:article_id])
      elsif params[:unit_id].present?
        @unit = Units::Unit.find_by(uuid: params[:unit_id])
      elsif params[:algorithm_id].present?
        @algorithm = Algorithms::Algorithm.find_by(uuid: params[:algorithm_id])
      elsif params[:algorithm_version_id].present?
        @algorithm_version = Algorithms::AlgorithmVersion.find_by(slug: params[:algorithm_version_id])
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_improvement
      @improvement = Improvements::Improvement.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def improvement_params
      params.require(:improvements_improvement).permit(:title, :content, :sources, :unit_id, :article_id, :algorithm_id,
        unit_version_improvements_attributes: [:unit_version_id],
        article_version_improvements_attributes: [:article_version_id]
      )
    end

    # def rebuild_technology_params
    #   if params[:improvements_improvement][:unit_version_improvement].present?
    #     technologies_ids = []
    #     params[:improvements_improvement][:unit_version_improvement].map{ |id| technologies_ids << {id: id} }
    #     params[:improvements_improvement][:unit_version_improvement] = technologies_ids
    #   end
    # end
end
