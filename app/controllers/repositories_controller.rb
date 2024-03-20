class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[ show edit update destroy ]

  # GET /repositories or /repositories.json
  def index
    @repositories = Repository.all
  end

  # GET /repositories/1 or /repositories/1.json
  def show
    # TODO: not only User but also Organization
    @repository_owner = User.where(username: params[:ownername]).first
    @target = @repository_owner.repositories.friendly.find(params[:id])

    # breadcrumbs
    binding.pry
    add_breadcrumb @repository_owner.ownername,
                   dashboard_path(username: @repository_owner.ownername),
                   {link_type: "profile_page"}
    add_breadcrumb @target.name,
                   target_repository_path(ownername: @repository_owner.ownername, id: @target.slug),
                   {link_type: "repository_page"}
  end

  # GET /repositories/new
  def new
    @repository = Repository.new
  end

  # GET /repositories/1/edit
  def edit
  end

  # POST /repositories or /repositories.json
  def create
    binding.pry
    service = Services::Repositories::Create.new(repository_params, current_user)
    service.call
    @repository = service.repository
    respond_to do |format|
      if @repository.errors.blank?

        binding.pry
        format.html { redirect_to target_repository_path(ownername: current_user.username, id: @repository),
                                  notice: "Repository was successfully created." }
        format.json { render :show, status: :created, location: @repository }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
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
    def set_repository
      @repository = Repository.friendly.find(params[:id])
      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @repository.slug
        return redirect_to repository_path(ownername: @repository.user.username,
                                              id: @repository.slug),
                           :status => :moved_permanently
      end
    end

    # Only allow a list of trusted parameters through.
    def repository_params
      params.require(:repository).permit(:name, :description, :is_private, :tag_list)
    end
end
