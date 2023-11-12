class SimpleClass::InterfaceGroupsController < ApplicationController
  before_action :set_interface_group, only: %i[ show edit update destroy ]
  before_action :set_target_simple_class, only: %i[ new create ]

  # GET /interface_groups or /interface_groups.json
  def index
    @interface_groups = SimpleClasses::InterfaceGroup.all
  end

  # GET /interface_groups/1 or /interface_groups/1.json
  def show
  end

  # GET /interface_groups/new
  def new
    binding.pry
    @interface_group = SimpleClasses::InterfaceGroup.new
  end

  # GET /interface_groups/1/edit
  def edit
    binding.pry
  end

  # POST /interface_groups or /interface_groups.json
  def create
    # @interface_group = SimpleClasses::InterfaceGroup.new(interface_group_params)

    binding.pry
    service = Services::SimpleClasses::InterfaceGroups::Create.new(interface_group_params, @target_simple_class)
    service.call
    simple_class = service.target_simple_class

    respond_to do |format|
      if service.errors.blank?
        # format.html { redirect_to interface_group_url(@interface_group), notice: "Interface group was successfully created." }
        format.html { redirect_to simple_class_path(username: simple_class.owner.username, id: simple_class.id),
                                  notice: "Actions group was successfully created." }
        format.json { render :show, status: :created, location: @interface_group }
      else
        @interface_group = service.interface_group
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @interface_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interface_groups/1 or /interface_groups/1.json
  def update
    binding.pry
    respond_to do |format|
      binding.pry
      if @interface_group.update(interface_group_params)
        simple_class = @interface_group.simple_class ? @interface_group.simple_class : @interface_group.root.simple_class
        # format.html { redirect_to interface_group_url(@interface_group), notice: "Interface group was successfully updated." }
        format.html { redirect_to simple_class_path(username: simple_class.owner.username, id: simple_class.id),
                                  notice: "Actions group was successfully updated." }
        format.json { render :show, status: :ok, location: @interface_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @interface_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interface_groups/1 or /interface_groups/1.json
  def destroy
    binding.pry
    simple_class = @interface_group.simple_class
    @interface_group.destroy

    binding.pry
    respond_to do |format|
      format.html { redirect_to simple_class_path(username: simple_class.owner.username, id: simple_class.id),
                                notice: "Actions group was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

    def set_target_simple_class
      if params[:target_simple_class].present?
        @target_simple_class = SimpleClasses::SimpleClass.where(id: params[:target_simple_class]).first
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_interface_group
      @interface_group = SimpleClasses::InterfaceGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def interface_group_params
      params.require(:simple_classes_interface_group).permit(:title, :description,
                                                             interface_members_attributes: [:id, :_destroy, :memberable_type, :memberable_id, :position ])
    end
end
