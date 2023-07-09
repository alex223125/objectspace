class DashboardsController < ApplicationController
  before_action :set_dashboard, only: %i[ edit update destroy ]

  # GET /dashboards or /dashboards.json
  # def index
  #   @dashboards = Dashboard.all
  # end

  # GET /dashboards/1 or /dashboards/1.json
  def show
    @target_user = User.where(username: params[:username]).first
    # @dashboard = Dashboard.where(user_id: params[:user_id]).first
    @dashboard = @target_user.dashboard

    # REDO, WE CAN ONLY BE IN ROOT FOLDER WTIH LOAD MORE BUTTON EVERYTHING ELSE LEADS TO FOLDER CONTROLLER
    # Case 1.we in some folder
    if params[:target_folder]
      @target_folder = Folder.where(id: params[:target_folder]).first
      @folders_tree_without_root = @target_folder.self_and_ancestors.where.not(parent_id: nil).reverse

      # breadcrumbs
      add_breadcrumb @target_user.username, dashboard_path(username: @target_user.username), {link_type: "profile_page"}
      @folders_tree_without_root.each do |folder|
        add_breadcrumb folder.title, dashboard_path(username: @target_user.username, target_folder: folder.id), {link_type: "folder_page"}
      end
    else
      # Case 2.we in root folder
      # breadcrumbs
      add_breadcrumb @target_user.username, dashboard_path(username: @target_user.username), {link_type: "profile_page"}
    end


  end

  def methodologies
    # folders
    # articles
    # units
    # algorithms
    # sort by creation updated date
  end

  # GET /dashboards/new
  def new
    @dashboard = Dashboard.new
  end

  # GET /dashboards/1/edit
  def edit
  end

  # POST /dashboards or /dashboards.json
  def create
    @dashboard = Dashboard.new(dashboard_params)

    respond_to do |format|
      if @dashboard.save
        format.html { redirect_to dashboard_url(@dashboard), notice: "Dashboard was successfully created." }
        format.json { render :show, status: :created, location: @dashboard }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dashboards/1 or /dashboards/1.json
  def update
    respond_to do |format|
      if @dashboard.update(dashboard_params)
        format.html { redirect_to dashboard_url(@dashboard), notice: "Dashboard was successfully updated." }
        format.json { render :show, status: :ok, location: @dashboard }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dashboards/1 or /dashboards/1.json
  def destroy
    @dashboard.destroy

    respond_to do |format|
      format.html { redirect_to dashboards_url, notice: "Dashboard was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dashboard
      @dashboard = Dashboard.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dashboard_params
      params.fetch(:dashboard, {})
    end
end
