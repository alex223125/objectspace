class Framework::FrameworksController < ApplicationController
  include Folderable
  include TechBreadcrumbable

  before_action :set_framework, only: %i[ show edit update destroy preview]
  before_action :set_target_folder, only: %i[ new create ]

  # GET /frameworks or /frameworks.json
  def index
    @frameworks = Frameworks::Framework.all
  end

  # GET /frameworks/1 or /frameworks/1.json
  def show
    technology_breadcrumbs(@framework)
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

    @root_class_container = @framework.class_containers.new(title: "This is root class container")
    @root_interface_group = @framework.interface_groups.new(title: "This is root interface group")
  end

  # GET /frameworks/1/edit
  def edit
  end

  # POST /frameworks or /frameworks.json
  def create
    # @framework = Frameworks::Framework.new(framework_params)
    binding.pry
    service = Services::Frameworks::Frameworks::Create.new(framework_params, @target_folder, current_user)

    binding.pry
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to framework_path(ownername: service.framework.ownerable.ownername, id: service.framework.slug),
                                  notice: "Framework was successfully created." }
        format.json { render :show, status: :created, location: service.framework }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: service.framework.errors, status: :unprocessable_entity }
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
    end

    # Only allow a list of trusted parameters through.
    def framework_params
      params.require(:frameworks_framework).permit(
        :title, :description, :tag_list,
        interface_groups_attributes, class_containers_attributes
      )
    end
end
