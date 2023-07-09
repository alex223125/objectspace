class SimpleClass::SimpleClassesController < ApplicationController
  include Folderable
  include TechBreadcrumbable

  before_action :set_simple_class, only: %i[ show edit update destroy preview ]
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

  # GET /simple_classes/new
  def new
    binding.pry
    if params[:class_type] == "decision_process_object_class"
      @class_type = SimpleClasses::TypeTypes[:decision_process_object_class]
    elsif params[:class_type] == "decision_object_class"
      @class_type = SimpleClasses::TypeTypes[:decision_object_class]
    elsif params[:class_type] == "decision_object_container_class"
      @class_type = SimpleClasses::TypeTypes[:decision_object_container_class]
    end

    @simple_class = SimpleClasses::SimpleClass.new
    @root_class_container = @simple_class.class_containers.new(title: "Root class container")
    @root_interface_group = @simple_class.interface_groups.new(title: "Root actions group")

    binding.pry
    service = Services::SimpleClasses::InterfaceGroups::CreateDefaultCollection.new(:decision_process_object_class)

    default_interface_groups = service.call
    @simple_class.interface_groups << default_interface_groups

    # @interface_group = @simple_class.interface_groups.new
  end

  # GET /simple_classes/1/edit
  def edit
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
    respond_to do |format|
      if @simple_class.update(simple_class_params)
        format.html { redirect_to simple_class_url(@simple_class), notice: "Simple class was successfully updated." }
        format.json { render :show, status: :ok, location: @simple_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @simple_class.errors, status: :unprocessable_entity }
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
      @simple_class = SimpleClasses::SimpleClass.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @simple_class.slug
        return redirect_to simple_class_path(username: @simple_class.owner.ownername,
                                             id: @simple_class.slug),
                           :status => :moved_permanently
      end
    end

    # Only allow a list of trusted parameters through.
    def simple_class_params
      params.require(:simple_classes_simple_class).permit(
        :title, :description, :type,
        :instructionable_type, :instructionable_id, :tag_list,
        interface_groups_attributes, class_containers_attributes
      )
    end

end
