class SimpleClass::ClassContainersController < ApplicationController
  include Containerable
  include TechBreadcrumbable

  before_action :set_class_container, only: %i[ show edit update destroy ]
  before_action :set_target_place, only: %i[ new create ]

  # GET /class_containers or /class_containers.json
  def index
    @class_containers = SimpleClasses::ClassContainer.all
  end

  # GET /class_containers/1 or /class_containers/1.json
  def show
    technology_breadcrumbs(@class_container)
  end

  # GET /class_containers/new
  def new
    @class_container = SimpleClasses::ClassContainer.new
    @back_path = containerable_back_path
  end

  # GET /class_containers/1/edit
  def edit
  end

  # POST /class_containers or /class_containers.json
  def create
    binding.pry
    service = Services::SimpleClasses::ClassContainers::Create.new(class_container_params, target_place, current_user)
    service.call

    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to class_container_path(ownername: service.class_container.related_simple_class.ownerable.ownername,
                                                       id: service.class_container),
                                                       notice: "Class container was successfully created." }
        format.json { render :show, status: :created, location: @class_container }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.class_container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /class_containers/1 or /class_containers/1.json
  def update
    respond_to do |format|
      if @class_container.update(class_container_params)
        format.html { redirect_to class_container_path(ownername: @class_container.related_simple_class.ownerable.ownername,
                                                       id: @class_container),
                                  notice: "Class container was successfully updated." }
        format.json { render :show, status: :ok, location: @class_container }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @class_container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /class_containers/1 or /class_containers/1.json
  def destroy

    #DOC: In case of no components redirect to simple class
    # otherwise to parent component
    binding.pry
    parent_class_container = @class_container.parent
    if parent_class_container.regular_functional_type?
      binding.pry
      redirect_path = class_container_path(ownername: parent_class_container.related_simple_class.ownerable.ownername,
                                           id: parent_class_container.slug)
    else
      binding.pry
      simple_class = @class_container.related_simple_class
      redirect_path = simple_class_path(ownername: simple_class.owner.ownername,
                                        id: simple_class.slug)
    end

    # TODO: Add service object which will delete everything + form with typing "DELETE COMPONENT + ITS NAME"
    binding.pry
    @class_container.destroy!
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: "Component was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_class_container
    binding.pry
    @class_container = SimpleClasses::ClassContainer.friendly.try(:find, params[:id])

    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    request_slug = params[:id]
    if request_slug != @class_container.slug
      return redirect_to simple_class_path(ownername: @class_container.related_simple_class.owner.ownername,
                                           id: @class_container.slug),
                         :status => :moved_permanently
    end
    # TODO: add in all controller with friendly find rescue from not found case
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Model not found"
    redirect_to :root
  end

  # Only allow a list of trusted parameters through.
  def class_container_params
    binding.pry
    params.require(:simple_classes_class_container).permit(:title, :description)
  end
end
