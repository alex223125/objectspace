class FoldersController < ApplicationController
  before_action :set_folder, only: %i[ show edit update destroy ]

  # GET /folders or /folders.json
  def index
    @folders = Folder.all
  end

  # GET /folders/1 or /folders/1.json
  def show
    @folder_owner = User.where(username: params[:username]).first
    # @target_folder = @folder_owner.folders.friendly.find(params[:id])
    binding.pry
    @target_folder = Folder.friendly.find(params[:id])

    # folders_tree_without_root = @target_folder.folders_tree_without_root.reverse
    folders_tree = @target_folder.self_and_ancestors.reverse
    repository = @target_folder.root.repository

    # breadcrumbs
    add_breadcrumb @folder_owner.ownername, dashboard_path(username: @folder_owner.ownername), {link_type: "profile_page"}
    add_breadcrumb repository.name, repository_path(username: @folder_owner.ownername, id: repository.slug), {link_type: "repository_page"}
    folders_tree.each do |folder|
      add_breadcrumb folder.title, target_folder_path(username: @folder_owner.ownername, id: folder.slug), {link_type: "folder_page"}
    end

  end

  # GET /folders/new
  def new
    binding.pry
    @folder = Folder.new
    if params[:target_type] == "folder"
      @target = Folder.friendly.find(params[:target])
      @target_type = "folder"
    elsif params[:target_type] == "repository"
      @target = Repository.friendly.find(params[:target])
      @target_type = "repository"
    end
  end

  # GET /folders/1/edit
  def edit
  end

  # POST /folders or /folders.json
  def create
    binding.pry
    if params[:target_repository_id].present?
      target = params[:target_repository_id]
      target_type = "repository"
    elsif params[:target_folder_id].present?
      target = params[:target_folder_id]
      target_type = "folder"
    end

    service = Services::Folders::Create.new(folder_params, current_user, target, target_type)

    binding.pry
    service.call

    if service.folder.parent.present?
      parent_folder = service.folder.parent
      path = target_folder_path(username: current_user.username, id: parent_folder.slug)
    else
      repository = service.folder.repository
      path = target_repository_path(username: current_user.username, id: repository.slug)
    end

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        binding.pry
        format.html { redirect_to path, notice: "Folder was successfully created." }
        format.json { render :show, status: :created, location: service.folder }
      else
        @target = service.target
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folders/1 or /folders/1.json
  def update
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to folder_url(@folder), notice: "Folder was successfully updated." }
        format.json { render :show, status: :ok, location: @folder }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1 or /folders/1.json
  def destroy
    @folder.destroy

    respond_to do |format|
      format.html { redirect_to folders_url, notice: "Folder was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @folder.slug
        return redirect_to target_folder_path(username: @folder.user.username,
                                             id: @folder.slug),
                           :status => :moved_permanently
      end
    end

    # Only allow a list of trusted parameters through.
    def folder_params
      params.require(:folder).permit(:title, :description, subfolders_attributes)
    end

    def subfolders_attributes
      {subfolders_attributes: [:title, :description, :_destroy, recursive_nested_groups_attr]}
    end

    def recursive_nested_groups_attr
      build_recursive_params(
        recursive_key: 'subfolders_attributes',
        parameters: params,
        permitted_attributes: [:title, :description, :_destroy]
      )
    end
end
