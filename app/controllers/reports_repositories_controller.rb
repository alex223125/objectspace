class ReportsRepositoriesController < ApplicationController
  # before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]
  before_action :authenticate_user!, only: [:create]
  before_action :set_reports_repository, only: %i[ show edit update destroy ]


  # GET /repositories/1 or /repositories/1.json
  def show
    binding.pry
    # TODO: not only User but also Organization
    @reports_repository_owner = User.where(username: params[:ownername]).first
    @target = @reports_repository_owner.reports_repositories.friendly.find(params[:id])

    # breadcrumbs
    binding.pry
    add_breadcrumb @reports_repository_owner.ownername,
                   dashboard_path(username: @reports_repository_owner.ownername),
                   {link_type: "owner_page"}
    add_breadcrumb "Reports repositories",
                   dashboard_path(username: @reports_repository_owner.ownername),
                   {link_type: "owner_page"}
    add_breadcrumb @target.title,
                   target_reports_repository_path(ownername: @reports_repository_owner.ownername, id: @target.slug),
                   {link_type: "reports_repository_page"}
  end

  # GET /repositories/new
  def new
    binding.pry
    @reports_repository = ReportsRepository.new
  end

  # GET /repositories/1/edit
  def edit
  end

  # POST /repositories or /repositories.json
  def create
    # binding.pry
    # authenticate_user!
    binding.pry
    service = Services::ReportsRepositories::Create.new(reports_repository_params, current_user)
    service.call

    @reports_repository = service.reports_repository
    respond_to do |format|
      if @reports_repository.errors.blank?

        binding.pry
        format.html { redirect_to target_reports_repository_path(ownername: current_user.username, id: @reports_repository),
                                  notice: "Reports repository was successfully created." }
        format.json { render :show, status: :created, location: @reports_repository }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reports_repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repositories/1 or /repositories/1.json
  def update
    service = Services::Repositories::Update.new(@repository, repository_params)
    service.call
    @repository = service.repository
    respond_to do |format|
      binding.pry
      if @repository.errors.blank?
        format.html { redirect_to target_repository_path(ownername: current_user.username, id: @repository),
                                  notice: "Repository was successfully updated." }
        format.json { render :show, status: :ok, location: @repository }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1 or /repositories/1.json
  def destroy
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to dashboard_path(username: current_user.username), notice: "Repository was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_reports_repository
    @reports_repository = ReportsRepository.friendly.find(params[:id])
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    request_slug = params[:id]
    if request_slug != @reports_repository.slug
      return redirect_to target_reports_repository_path(ownername: @reports_repository.user.username,
                                         id: @reports_repository.slug),
                         :status => :moved_permanently
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Model not found"
    redirect_to :root
  end

  # Only allow a list of trusted parameters through.
  def reports_repository_params
    params.require(:reports_repository).permit(:title, :description, :is_private, :tag_list)
  end
end
