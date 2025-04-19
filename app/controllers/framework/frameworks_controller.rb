class Framework::FrameworksController < ApplicationController
  include Placeable
  include TechBreadcrumbable

  before_action :set_framework, only: %i[ show edit update destroy preview]
  before_action :set_target_place, only: %i[ new create ]

  # GET /frameworks or /frameworks.json
  def index
    @frameworks = Frameworks::Framework.all
  end

  # GET /frameworks/1 or /frameworks/1.json
  def show
    technology_breadcrumbs(@framework)
  end

  def tree_map
    # TODO: create query object with 1 query with jons, current solution makes 4 queries
    # @framework = Frameworks::Framework.where(uuid: params[:id])
    #                     .includes(:interface_groups)
    #                     .includes(interface_groups: [interface_members: [:memberable]]).first

    # @framework = Frameworks::Framework.where(uuid: params[:id])
    #                  .includes(:framework_folders)
    #                  .includes(framework_members: [:memberable]).first

    @framework = Frameworks::Framework.where(uuid: params[:id])
                     .includes(framework_folders: [framework_members: [:framework_memberable]]).first

    # @framework = Frameworks::Framework.where(uuid: "42ba8c89-2f92-46d9-9b5e-6d0937cf52d8").includes(:framework_folders).includes(framework_members: [:memberable]).first

    binding.pry
    if params[:map_type] == "technology_pick"
      # DOC:
      # technology_pick - we have "select" buttons
      # regular view - we only see what's inside without select
      locals = { framework: @framework, leaf_type: "technology_pick"}
    else
      locals = { framework: @framework, leaf_type: "regular_view"}
    end

    path = "framework/framework_dynamic_tree_view/main"

    respond_to do |format|
      format.json {
        render json: { tree: render_to_string(partial: path,
                                              formats: [:html],
                                              locals: locals)}
      }
    end
  end

  def preview
    binding.pry
    path = "framework/frameworks/preview"
    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
                                                 formats: [:html])}
      }
    end
  end

  # GET /frameworks/new
  def new
    @framework = Frameworks::Framework.new

    # OLD VERSION
    # 1.0 Default setup
    # 1.1 Default interface group (for all types of classes)
    # rig_description = "This is main interface group for all uncategorized actions."
    # @root_interface_group = @framework.interface_groups.new(title: "Main", description: rig_description,
    #                                                            functional_type: InterfaceGroups::FunctionalTypes[:root],
    #                                                            creator: current_user)
    # 1.2 Default class container for DOC instaces
    # service = Services::SimpleClasses::ClassContainers::BuildRootContainer.new(current_user, @framework)
    # service.call
    # @root_class_container = service.class_container

    # NEW VERSION OF FRAMEWORK ARCHITECTURE
    folder_description = "This is main framework folder for all uncategorized content."
    @root_framework_folder = @framework.framework_folders.new(title: "Main", description: folder_description,
                                                              creator: current_user,
                                                              functional_type: FrameworkFolders::FunctionalTypes[:root])
  end

  # GET /frameworks/1/edit
  def edit
  end

  # POST /frameworks or /frameworks.json
  def create
    binding.pry
    service = Services::Frameworks::Frameworks::Create.new(framework_params, target_place, current_user, current_user)

    binding.pry
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to framework_path(ownername: service.framework.ownerable.ownername, id: service.framework.slug),
                                  notice: "Framework was successfully created." }
        format.json { render :show, status: :created, location: service.framework }
      else
        format.html { render :new, status: :unprocessable_entity,
                             assigns: { framework: service.framework, permission: service.permission } }
      end
    end
  end

  # PATCH/PUT /frameworks/1 or /frameworks/1.json
  def update
    respond_to do |format|
      if @framework.update(framework_params)
        format.html { redirect_to framework_url(@framework), notice: "Framework was successfully updated." }
        format.json { render :show, status: :ok, location: @framework }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @framework.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /frameworks/1 or /frameworks/1.json
  def destroy
    @framework.destroy

    respond_to do |format|
      format.html { redirect_to frameworks_url, notice: "Framework was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_framework
      @framework = Frameworks::Framework.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @framework.slug
        return redirect_to framework_path(ownername: @framework.owner.ownername,
                                             id: @framework.slug),
                           :status => :moved_permanently
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Model not found"
      redirect_to :root
    end

    # Only allow a list of trusted parameters through.
    def framework_params
      binding.pry
      params.require(:frameworks_framework).permit(
          :title, :description, :tag_list,
          framework_folders_attributes: [:title, :description, :creator_id, :functional_type]
      )

      # OLD ARCHITECTURE
      # params.require(:frameworks_framework).permit(
      #   :title, :description, :tag_list,
      #   interface_groups_attributes, class_containers_attributes
      # )
    end

end
