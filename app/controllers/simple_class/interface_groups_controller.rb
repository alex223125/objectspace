class SimpleClass::InterfaceGroupsController < ApplicationController
  before_action :set_interface_group, only: %i[ show edit update destroy ]

  # GET /interface_groups or /interface_groups.json
  def index
    @interface_groups = SimpleClasses::InterfaceGroup.all
  end

  # GET /interface_groups/1 or /interface_groups/1.json
  def show
  end

  # GET /interface_groups/new
  def new
    @interface_group = SimpleClasses::InterfaceGroup.new
  end

  # GET /interface_groups/1/edit
  def edit
  end

  # POST /interface_groups or /interface_groups.json
  def create
    @interface_group = SimpleClasses::InterfaceGroup.new(interface_group_params)

    respond_to do |format|
      if @interface_group.save
        format.html { redirect_to interface_group_url(@interface_group), notice: "Interface group was successfully created." }
        format.json { render :show, status: :created, location: @interface_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @interface_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interface_groups/1 or /interface_groups/1.json
  def update
    respond_to do |format|
      if @interface_group.update(interface_group_params)
        format.html { redirect_to interface_group_url(@interface_group), notice: "Interface group was successfully updated." }
        format.json { render :show, status: :ok, location: @interface_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @interface_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interface_groups/1 or /interface_groups/1.json
  def destroy
    @interface_group.destroy

    respond_to do |format|
      format.html { redirect_to interface_groups_url, notice: "Interface group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface_group
      @interface_group = SimpleClasses::InterfaceGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def interface_group_params
      params.require(:interface_group).permit(:title, :description)
    end
end
