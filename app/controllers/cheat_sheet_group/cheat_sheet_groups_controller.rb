class CheatSheetGroup::CheatSheetGroupsController < ApplicationController
  include Folderable

  before_action :set_cheat_sheet_group, only: %i[ show edit update destroy preview ]
  before_action :set_target_folder, only: %i[ new create ]

  # GET /cheat_sheet_groups or /cheat_sheet_groups.json
  # def index
  #   @cheat_sheet_groups = CheatSheetGroup.all
  # end

  # GET /cheat_sheet_groups/1 or /cheat_sheet_groups/1.json
  def show
  end

  def preview
    binding.pry
    if params[:preview_type] == "cheat_sheet_group_section_preview"
      path = "shared/tech_previews/basic_preview"
      scenario = "cheat_sheet_group_section_preview"
    end

    binding.pry
    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
          formats: [:html],
          locals: {cheat_sheet_group: @cheat_sheet_group, scenario: scenario})}
      }
    end
  end

  # GET /cheat_sheet_groups/new
  def new
    @cheat_sheet_group = CheatSheetGroups::CheatSheetGroup.new
    @cheat_sheet_group_version = @cheat_sheet_group.cheat_sheet_group_versions.new
  end

  # GET /cheat_sheet_groups/1/edit
  def edit
  end

  # POST /cheat_sheet_groups or /cheat_sheet_groups.json
  def create
    binding.pry
    # TODO: not only current user as owner, org also
    service = Services::CheatSheetGroups::CheatSheetGroups::Create.new(cheat_sheet_group_params, target_place, current_user)
    service.call
    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to cheat_sheet_group_version_path(ownername: service.cheat_sheet_group.ownerable.ownername,
                                                                 id: service.cheat_sheet_group.default_version.slug),
                                                                 notice: "Cheat sheet group was successfully created." }
        format.json { render :show, status: :created, location: @cheat_sheet_group }
      else
        @cheat_sheet_group = service.cheat_sheet_group
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cheat_sheet_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cheat_sheet_groups/1 or /cheat_sheet_groups/1.json
  def update
    respond_to do |format|
      if @cheat_sheet_group.update(cheat_sheet_group_params)
        format.html { redirect_to cheat_sheet_group_url(@cheat_sheet_group), notice: "Cheat sheet group was successfully updated." }
        format.json { render :show, status: :ok, location: @cheat_sheet_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cheat_sheet_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cheat_sheet_groups/1 or /cheat_sheet_groups/1.json
  def destroy
    @cheat_sheet_group.destroy

    respond_to do |format|
      format.html { redirect_to cheat_sheet_groups_url, notice: "Cheat sheet group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cheat_sheet_group
      @cheat_sheet_group = CheatSheetGroups::CheatSheetGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cheat_sheet_group_params
      binding.pry
      params.require(:cheat_sheet_groups_cheat_sheet_group).permit(:title, :source_page_description, :tag_list,
                                                                  cheat_sheet_group_versions_attributes: [:id, :title, :description, :_destroy,
                                                                                                          sections_attributes: [:id, :sectionable_type, :sectionable_id, :_destroy]])
    end
end
