class Unit::UnitVersionsController < ApplicationController
  include TechBreadcrumbable
  include Commentable
  include Memberable

  before_action :set_unit_version, only: %i[ show edit update destroy preview ]

  # GET /unit_versions or /unit_versions.json
  def index
    @unit_versions = Units::UnitVersion.all
  end

  # GET /unit_versions/1 or /unit_versions/1.json
  def show
    binding.pry
    if container_members_present?(@unit_version) || interface_members_present?(@unit_version)
      binding.pry
      redirect_to_member(@unit_version)
    else
      binding.pry
      technology_breadcrumbs(@unit_version)
      @unit = @unit_version.unit
    end
  end

  # GET /unit_versions/new
  def new
    binding.pry
    set_unit
    @unit_version = @unit.unit_versions.new
  end

  # GET /unit_versions/1/edit
  def edit
    binding.pry
    @unit = @unit_version.unit
    @target_folder = @unit.folder
  end

  # POST /unit_versions or /unit_versions.json
  def create
    binding.pry
    # @unit_version = Units::UnitVersion.new(unit_version_params)
    service = Services::Units::UnitVersions::Create.new(unit_version_params)
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        binding.pry
        format.html { redirect_to unit_version_path(ownername: service.unit_version.unit.ownerable.ownername,
                                                       id: service.unit_version.slug),
                                  notice: "Method was successfully created." }
        format.json { render :show, status: :created, location: @unit_version }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.unit_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unit_versions/1 or /unit_versions/1.json
  def update
    binding.pry
    set_unit
    respond_to do |format|
      if @unit_version.update(unit_version_params)
        binding.pry
        format.html { redirect_to unit_version_path(ownername: @unit_version.unit.ownerable.ownername,
                                                    id: @unit_version.slug),
                                  notice: "Method was successfully updated." }

        format.json { render :show, status: :ok, location: @unit_version }
      else
        binding.pry
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @unit_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_versions/1 or /unit_versions/1.json
  def destroy
    @unit_version.destroy

    respond_to do |format|
      format.html { redirect_to unit_versions_url, notice: "Unit version was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_unit
      @unit = Units::Unit.find_by(id: params[:unit_id]) || Units::Unit.find_by(id: unit_version_params[:unit_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_unit_version
      @unit_version = Units::UnitVersion.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @unit_version.slug
        return redirect_to unit_version_path(ownername: @unit_version.owner.ownername,
                                             id: @unit_version.slug),
                           :status => :moved_permanently
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Model not found"
      redirect_to :root
    end

    # Only allow a list of trusted parameters through.
    def unit_version_params
      params.require(:units_unit_version).permit(:title, :instruction, :description, :solves_the_problem, :target_audience,
                                                 :sources, :additional_information, :unit_id,
                                                 attachments_attributes: [:id, :attachable_id,
                                                                          :attachable_type, :_destroy],
                                                 usage_examples_attributes: [:id, :title, :content,
                                                                                  :sources, :_destroy])
    end
end
