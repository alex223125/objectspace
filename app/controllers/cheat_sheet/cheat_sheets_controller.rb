class CheatSheet::CheatSheetsController < ApplicationController
  include Folderable

  before_action :set_cheat_sheet, only: %i[ show edit update destroy preview ]
  before_action :set_target_folder, only: %i[ new create ]

  # GET /cheat_sheets or /cheat_sheets.json
  def index
    @cheat_sheets = CheatSheet.all
  end

  # GET /cheat_sheets/1 or /cheat_sheets/1.json
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
                                                 locals: {cheat_sheet: @cheat_sheet, scenario: scenario})}
      }
    end
  end

  # GET /cheat_sheets/new
  def new
    @cheat_sheet = CheatSheets::CheatSheet.new
    @cheat_sheet_version = @cheat_sheet.cheat_sheet_versions.new
  end

  # GET /cheat_sheets/1/edit
  def edit
  end

  # POST /cheat_sheets or /cheat_sheets.json
  def create
    binding.pry
    service = Services::CheatSheets::CheatSheets::Create.new(cheat_sheet_params, target_place, current_user)

    binding.pry
    service.call
    @cheat_sheet = service.cheat_sheet
    set_redirect_after_create_path

    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to @redirect_after_create_path,
                                  notice: "Cheat sheet was successfully created." }
        format.json { render :show, status: :created, location: @cheat_sheet }
      else
        @cheat_sheet = service.cheat_sheet
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cheat_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cheat_sheets/1 or /cheat_sheets/1.json
  def update
    respond_to do |format|
      if @cheat_sheet.update(cheat_sheet_params)
        format.html { redirect_to cheat_sheet_url(@cheat_sheet), notice: "Cheat sheet was successfully updated." }
        format.json { render :show, status: :ok, location: @cheat_sheet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cheat_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cheat_sheets/1 or /cheat_sheets/1.json
  def destroy
    @cheat_sheet.destroy

    respond_to do |format|
      format.html { redirect_to cheat_sheets_url, notice: "Cheat sheet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_redirect_after_create_path
    if target_place.class == SimpleClasses::InterfaceGroup
      interface_member = @cheat_sheet.interface_members.last
      @redirect_after_create_path = interface_member_path(ownername: interface_member.simple_class.ownerable.ownername,
                                                          id: interface_member.slug)
    else
      @redirect_after_create_path = cheat_sheet_version_path(ownername: @cheat_sheet.ownerable.ownername,
                                                             id: @cheat_sheet.default_version.slug)
    end
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_cheat_sheet
      binding.pry
      @cheat_sheet = CheatSheets::CheatSheet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cheat_sheet_params
      binding.pry
      params.require(:cheat_sheets_cheat_sheet).permit(:title, :source_page_description, :tag_list,
                                          cheat_sheet_versions_attributes: [:id, :title, :description,
                                            notes_attributes: [:id, :title, :content, :_destroy,
                                              link_attachments_attributes: [:id, :linkable_type, :linkable_id, :_destroy]
                                            ]
                                          ])
    end
end


