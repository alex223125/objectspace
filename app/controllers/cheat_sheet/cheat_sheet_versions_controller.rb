class CheatSheet::CheatSheetVersionsController < ApplicationController
  include TechBreadcrumbable
  include Memberable

  before_action :set_cheat_sheet_version, only: %i[ show edit update destroy ]

  # GET /cheat_sheet_versions or /cheat_sheet_versions.json
  def index
    @cheat_sheet_versions = CheatSheetVersion.all
  end

  # GET /cheat_sheet_versions/1 or /cheat_sheet_versions/1.json
  def show
    if container_members_present?(@cheat_sheet_version) || interface_members_present?(@cheat_sheet_version)
      redirect_to_member(@cheat_sheet_version)
    else
      technology_breadcrumbs(@cheat_sheet_version)
      @cheat_sheet = @cheat_sheet_version.cheat_sheet
    end
  end

  # GET /cheat_sheet_versions/new
  def new
    @cheat_sheet_version = CheatSheetVersion.new
  end

  # GET /cheat_sheet_versions/1/edit
  def edit
  end

  # POST /cheat_sheet_versions or /cheat_sheet_versions.json
  def create
    @cheat_sheet_version = CheatSheetVersion.new(cheat_sheet_version_params)

    respond_to do |format|
      if @cheat_sheet_version.save
        format.html { redirect_to cheat_sheet_version_url(@cheat_sheet_version), notice: "Cheat sheet version was successfully created." }
        format.json { render :show, status: :created, location: @cheat_sheet_version }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cheat_sheet_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cheat_sheet_versions/1 or /cheat_sheet_versions/1.json
  def update
    binding.pry
    respond_to do |format|

      binding.pry
      if @cheat_sheet_version.update(cheat_sheet_version_params)
        format.html { redirect_to cheat_sheet_version_url(@cheat_sheet_version), notice: "Cheat sheet version was successfully updated." }
        format.json { render :show, status: :ok, location: @cheat_sheet_version }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cheat_sheet_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cheat_sheet_versions/1 or /cheat_sheet_versions/1.json
  def destroy
    @cheat_sheet_version.destroy

    respond_to do |format|
      format.html { redirect_to cheat_sheet_versions_url, notice: "Cheat sheet version was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cheat_sheet_version
      @cheat_sheet_version = CheatSheets::CheatSheetVersion.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @cheat_sheet_version.slug
        return redirect_to cheat_sheet_version_path(ownername: @cheat_sheet_version.owner.ownername,
                                                    id: @cheat_sheet_version.slug),
                           :status => :moved_permanently
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Model not found"
      redirect_to :root
    end

    # Only allow a list of trusted parameters through.
    def cheat_sheet_version_params
      binding.pry
      params.require(:cheat_sheets_cheat_sheet_version).permit(:title, :description,
                                                  notes_attributes: [:id, :title, :content, :_destroy,
                                                                      link_attachments_attributes: [:id, :linkable_type, :linkable_id, :_destroy]
        ])
    end
end
