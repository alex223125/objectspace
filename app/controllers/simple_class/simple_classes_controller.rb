class SimpleClass::SimpleClassesController < ApplicationController
  include Folderable
  include TechBreadcrumbable

  before_action :set_simple_class, only: %i[ show edit update destroy preview]
  before_action :set_target_folder, only: %i[ new create ]

  # GET /simple_classes or /simple_classes.json
  def index
    @simple_classes = SimpleClasses::SimpleClass.all
  end

  # GET /simple_classes/1 or /simple_classes/1.json
  def show
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
      locals = { simple_class: @simple_class, leaf_type: "technology_pick"}
    else
      locals = { simple_class: @simple_class, leaf_type: "regular_view"}
    end

    path = "simple_class/simple_classes/partials/dynamic_tree_view/main"


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
    if params[:class_type] == "decision_process_object_class"
      @class_type = SimpleClasses::FunctionalTypes[:decision_process_object_class]
    elsif params[:class_type] == "decision_object_class"
      @class_type = SimpleClasses::FunctionalTypes[:decision_object_class]
    elsif params[:class_type] == "decision_object_container_class"
      @class_type = SimpleClasses::FunctionalTypes[:decision_object_container_class]
    end

    @simple_class = SimpleClasses::SimpleClass.new

    @root_class_container = @simple_class.class_containers.new(title: "Main")

    rig_description = "This is main interface group for all uncategorized actions."
    @root_interface_group = @simple_class.interface_groups.new(title: "Main", description: rig_description)

    binding.pry
    service = Services::SimpleClasses::InterfaceGroups::CreateDefaultCollection.new(:decision_process_object_class)

    default_interface_groups = service.call
    @simple_class.interface_groups << default_interface_groups

    # @interface_group = @simple_class.interface_groups.new
  end

  # GET /simple_classes/1/edit
  def edit
    binding.pry
    @root_interface_group = @simple_class.root_interface_group
    @class_type = @simple_class.functional_type
  end

  # POST /simple_classes or /simple_classes.json
  def create
    binding.pry
    service = Services::SimpleClasses::SimpleClasses::Create.new(simple_class_params, @target_folder, current_user)
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to simple_class_path(username: service.simple_class.owner.ownername,
                                                         id: service.simple_class.slug),
                                  notice: "Class was successfully created." }
        format.json { render :show, status: :created, location: service.simple_class }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.simple_class.errors, status: :unprocessable_entity }
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
        format.html { redirect_to simple_class_path(username: service.simple_class.owner.ownername, id: service.simple_class.slug),
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
      @simple_class = SimpleClasses::SimpleClass.friendly.try(:find, params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @simple_class.slug
        return redirect_to simple_class_path(username: @simple_class.owner.ownername,
                                             id: @simple_class.slug),
                           :status => :moved_permanently
      end
      # TODO: add in all controller with friendly find rescue from not found case
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Model not found"
      redirect_to :root
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

end
