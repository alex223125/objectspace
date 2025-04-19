class SimpleClass::SimpleClassesController < ApplicationController
  include Placeable
  include TechBreadcrumbable
  include Memberable

  before_action :set_simple_class, only: %i[ show edit update destroy ]
  before_action :set_target_place, only: %i[ new create ]
  before_action :friendly_find_simple_class, only: %i[ preview ]


  # GET /simple_classes or /simple_classes.json
  def index
    @simple_classes = SimpleClasses::SimpleClass.all
  end

  # GET /simple_classes/1 or /simple_classes/1.json
  def show
    binding.pry
    # TODO: can simpleclass be inside container member or inside interface mamber?
    # in models we only have memberable for framework, not for simple class

    # if container_members_present?(@simple_class) || interface_members_present?(@simple_class)
    #   binding.pry
    #   redirect_to_member(@simple_class)
    # else
    #   binding.pry
    #   technology_breadcrumbs(@simple_class)
    # end
    technology_breadcrumbs(@simple_class)
  end

  def preview
    binding.pry
    path = "simple_class/simple_classes/partials/preview/simple_class"

    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
                                                 formats: [:html])}
      }
    end
  end

  def tree_view
    binding.pry
    @simple_class = SimpleClasses::SimpleClass.find(params[:id])

    hash_tree = @simple_class.root_interface_group.hash_tree
    root_interface_group = hash_tree.keys[0]

    @root_actions = root_interface_group.interface_members
    @children_interface_groups = root_interface_group.children

    path = "simple_class/simple_classes/partials/tree_view/main"

    binding.pry
    respond_to do |format|
      format.json {
        render json: { tree_view: render_to_string(partial: path,
                                                 formats: [:html],
                                                 locals: { root_actions: @root_actions,
                                                           children_interface_groups: @children_interface_groups })}
      }
    end

  end

  def tree_map
    # TODO: create query object with 1 query with jons, current solution makes 4 queries
    @simple_class = SimpleClasses::SimpleClass.where(uuid: params[:id])
                                              .includes(:simple_class_attributes, :interface_groups)
                                              .includes(interface_groups: [interface_members: [:memberable]]).first

    binding.pry
    if params[:map_type] == "technology_pick"
      locals = { class_layer_entity: @simple_class, leaf_type: "technology_pick"}
    else
      locals = { class_layer_entity: @simple_class, leaf_type: "regular_view"}
    end

    path = "shared_class_layer/simple_class_dynamic_tree_view/main"


    respond_to do |format|
      format.json {
        render json: { tree: render_to_string(partial: path,
                                                   formats: [:html],
                                                   locals: locals)}
      }
    end
  end

  # GET /simple_classes/new
  def new
    binding.pry
    # Detect what type of class we will create
    if params[:class_type] == "decision_process_object_class"
      @class_type = SimpleClasses::FunctionalTypes[:decision_process_object_class]
    elsif params[:class_type] == "decision_object_class"
      @class_type = SimpleClasses::FunctionalTypes[:decision_object_class]
    elsif params[:class_type] == "decision_object_container_class"
      @class_type = SimpleClasses::FunctionalTypes[:decision_object_container_class]
    end


    @simple_class = SimpleClasses::SimpleClass.new

    # 1.0 Default setup
    # 1.1 Default interface group (for all types of classes)
    rig_description = "This is main interface group for all uncategorized actions."
    binding.pry
    @root_interface_group = @simple_class.interface_groups.new(title: "Main", description: rig_description,
                                                               functional_type: InterfaceGroups::FunctionalTypes[:root],
                                                               creator: current_user)

    # 1.2 Default class container for DOC
    if @class_type == SimpleClasses::FunctionalTypes[:decision_object_container_class]
      service = Services::SimpleClasses::ClassContainers::BuildRootContainer.new(current_user, @simple_class)
      service.call
      @root_class_container = service.class_container
    end

    # TODO: doesnt work, fix it
    # TODO: do this as option to fill with defaut data in the form
    # 1 click on the button 2 these parameters in the form
    # service = Services::SimpleClasses::InterfaceGroups::CreateDefaultCollection.new(:decision_process_object_class)
    # default_interface_groups = service.call
    # @simple_class.interface_groups << default_interface_groups
  end

  # GET /simple_classes/1/edit
  def edit
    binding.pry
    @root_interface_group = @simple_class.root_interface_group
    @root_class_container = @simple_class.root_class_container
    @class_type = @simple_class.functional_type
  end

  # POST /simple_classes or /simple_classes.json
  def create
    binding.pry
    service = Services::SimpleClasses::SimpleClasses::Create.new(simple_class_params, target_place, current_user, current_user)
    service.call
    binding.pry
    respond_to do |format|
      if service.errors.blank?
        @simple_class = service.simple_class
        set_redirect_after_success_create_path
        binding.pry
        format.html { redirect_to @redirect_after_success_create_path, notice: "Class was successfully created." }
        # format.json { render :show, status: :created, location: service.simple_class }
      else
        binding.pry
        format.html { render :new, status: :unprocessable_entity,
                             assigns: { simple_class: service.simple_class, permission: service.permission } }
        # format.json { render json: service.simple_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /simple_classes/1 or /simple_classes/1.json
  def update
    binding.pry
    service = Services::SimpleClasses::SimpleClasses::Update.new(simple_class_params, @simple_class)
    service.call

    respond_to do |format|
      if service.errors.blank?
        binding.pry
        format.html { redirect_to simple_class_path(ownername: service.simple_class.owner.ownername, id: service.simple_class.slug),
                                  notice: "Simple class was successfully updated." }
        format.json { render :show, status: :ok, location: @simple_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: service.simple_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simple_classes/1 or /simple_classes/1.json
  def destroy
    @simple_class.destroy

    respond_to do |format|
      format.html { redirect_to simple_classes_url, notice: "Simple class was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_simple_class
      binding.pry
      friendly_find_simple_class
      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @simple_class.slug
        return redirect_to simple_class_path(ownername: @simple_class.owner.ownername,
                                             id: @simple_class.slug),
                           :status => :moved_permanently
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Model not found"
      redirect_to :root
    end

    def friendly_find_simple_class
      @simple_class = SimpleClasses::SimpleClass.friendly.try(:find, params[:id])
    end

    # Only allow a list of trusted parameters through.
    def simple_class_params
      params.require(:simple_classes_simple_class).permit(
        :title, :description, :functional_type, :source_page_description,
        :instructionable_type, :instructionable_id, :tag_list,
        interface_groups_attributes, class_containers_attributes,
        simple_class_attributes_attributes: [:id, :title, :description, :_destroy,
                                             articles_simple_class_attributes_attributes: [:id, :article_id, :_destroy]]
      )
    end

    def set_redirect_after_success_create_path
      if @simple_class.related_framework.present?
        # container_member = @simple_class.framework_container_members.last
        # closest_class_layer_entity = container_member.class_container.closest_class_layer_entity
        # @redirect_after_success_create_path = container_member_path(ownername: closest_class_layer_entity.ownerable.ownername,
        #                                                             id: container_member.slug)
        framework_folder_member = @simple_class.framework_members.last
        framework = framework_folder_member.closest_framework
        @redirect_after_success_create_path = framework_member_path(ownername: framework.ownerable.ownername,
                                                                    id: framework_folder_member.slug)

      else
        @redirect_after_success_create_path = simple_class_path(ownername: @simple_class.owner.ownername, id: @simple_class.slug)
      end
    end
end
