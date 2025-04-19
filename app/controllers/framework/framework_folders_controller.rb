class Framework::FrameworkFoldersController < ApplicationController
  include TechBreadcrumbable
  include Placeable
  # include Commentable

  # before_action :set_container_member, only: %i[ show edit update destroy ]
  before_action :set_framework_folder, only: %i[ show edit update destroy ]
  before_action :set_target_place, only: %i[ new create ]


  # GET /container_members/1 or /container_members/1.json
  def show
    technology_breadcrumbs(@framework_folder)
  end

  def new
    @framework_folder = Frameworks::FrameworkFolder.new
  end

  def edit
  end

  def create
    binding.pry
    service = Services::Frameworks::FrameworkFolders::Create.new(framework_folder_params, target_place, current_user)
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?
        binding.pry
        @framework_folder = service.framework_folder

        binding.pry
        set_redirect_after_create_path

        binding.pry
        format.html { redirect_to @redirect_after_create_path, notice: "Framework folder was successfully created." }
        # format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity,
                             assigns: { article: service.framework_folder, errors: service.errors } }
        # @article = service.article
        # format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    binding.pry
    respond_to do |format|
      binding.pry
      if @framework_folder.update(framework_folder_params)
        binding.pry
        # format.html { redirect_to article_version_url(@article_version), notice: "Article version was successfully updated." }
        format.html { redirect_to framework_folder_path(ownername: @framework_folder.related_framework.ownerable.ownername,
                                                        id: @framework_folder.slug),
                                  notice: "Framework folder was successfully updated." }

        # format.json { render :show, status: :ok, location: @article_version }
      else
        format.html { render :edit, status: :unprocessable_entity }
        # format.json { render json: @article_version.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    parent_folder = @framework_folder.parent
    if parent_folder.functional_type == FrameworkFolders::FunctionalTypes[:root]
      framework = @framework_folder.related_framework
      redirect_path = framework_path(ownername: framework.owner.ownername, id: framework.slug)
    else
      redirect_path = framework_folder_path(ownername: parent_folder.related_framework.ownerable.ownername,
                                            id: parent_folder.slug)
    end

    @framework_folder.destroy

    respond_to do |format|
      format.html { redirect_to redirect_path, notice: "Framework folder was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_redirect_after_create_path
    @redirect_after_create_path = framework_folder_path(ownername: @framework_folder.related_framework.ownerable.ownername,
                                                       id: @framework_folder.slug)
  end

  def set_framework_folder
    binding.pry
    @framework_folder = Frameworks::FrameworkFolder.friendly.try(:find, params[:id])

    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    request_slug = params[:id]
    if request_slug != @framework_folder.slug
      return redirect_to framework_folder_path(ownername: @framework_folder.framework.owner.ownername,
                                               id: @framework_folder.slug),
                         :status => :moved_permanently
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Model not found"
    redirect_to :root
  end

  def framework_folder_params
    binding.pry
    params.require(:frameworks_framework_folder).permit(:title, :description, :functional_type)
  end
end
