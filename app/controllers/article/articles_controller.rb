class Article::ArticlesController < ApplicationController
  include Folderable

  before_action :set_article, only: %i[ show edit update destroy preview dynamic_view ]
  before_action :set_target_folder, only: %i[ new create ]

  # GET /articles or /articles.json
  def index
    @articles = Articles::Article.all
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  def preview
    binding.pry
    if params[:preview_type] == "basic_preview"
      path = "article/articles/previews/basic_preview"
    elsif params[:preview_type] == "small_line_preview"
      path = "article/articles/previews/small_line_preview"
    elsif params[:preview_type] == "algorithm_step_attachment_preview"
      path = "article/articles/previews/algorithm_step_attachment_preview"
    end

    binding.pry
    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
                                                 formats: [:html])}
      }
    end
  end

  def dynamic_view
    binding.pry
    @article_version = @article.default_version
    if params[:type] == "regular"
      path = "article/article_versions/dynamic_view/main"
    end


    respond_to do |format|
      format.json {
        render json: { dynamic_view: render_to_string(partial: path,
                                              formats: [:html])}
      }
    end
  end

  # GET /articles/new
  def new
    @article = Articles::Article.new
    @article_version = @article.article_versions.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    binding.pry
    # @article = Articles::Article.new(article_params)
    target_place = @target_repository || @target_folder
    service = Services::Articles::Articles::Create.new(article_params, target_place, current_user)
    service.call

    respond_to do |format|

      binding.pry
      if service.errors.blank?
        format.html { redirect_to article_version_path(username: service.article.ownerable.ownername,
                                                       id: service.article.default_version.slug),
                                  notice: "Article was successfully created." }
        # format.html { redirect_to algorithm_algorithm_version_path(service.algorithm.default_version), notice: "Algorithm was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        @article = service.article
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to article_url(@article), notice: "Article was successfully updated." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    binding.pry
    @folder = @article.folder
    @article.destroy

    respond_to do |format|
      format.html { redirect_to target_folder_path(username: @folder.user.username, id: @folder.id), notice: "Article was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      binding.pry
      @article = Articles::Article.find_by(uuid: params[:id]) || Articles::Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:articles_article).permit(:title, :default_version_id, :visibility_status, :source_page_description,
                                               :tag_list,
                                               article_versions_attributes: [:title, :solves_the_problem, :content,
                                                                             :sources, :additional_information,
                                                                             attachments_attributes: [:id, :attachable_id,
                                                                                                      :attachable_type, :_destroy]])
    end
end
