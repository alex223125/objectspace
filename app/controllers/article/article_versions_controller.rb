class Article::ArticleVersionsController < ApplicationController
  include TechBreadcrumbable
  before_action :set_article_version, only: %i[ show edit update destroy ]

  # GET /article_versions or /article_versions.json
  def index
    @article_versions = Articles::ArticleVersion.all
  end

  # GET /article_versions/1 or /article_versions/1.json
  def show
    technology_breadcrumbs(@article_version)
    @article = @article_version.article
    @related_articles = @article.find_related_tags.limit(3)
    @owner_articles = @article.ownerable.articles
  end

  # GET /article_versions/new
  def new
    set_article
    @article_version = @article.article_versions.new
  end

  # GET /article_versions/1/edit
  def edit
    @article = @article_version.article
    @target_folder = @article.folder
  end

  # POST /article_versions or /article_versions.json
  def create
    binding.pry
    @article_version = Articles::ArticleVersion.new(article_version_params)

    respond_to do |format|
      binding.pry
      if @article_version.save
        format.html { redirect_to article_version_path(ownername: @article_version.article.ownerable.ownername,
                                                       id: @article_version.slug),
                                  notice: "Article version was successfully created." }
        # format.json { render :show, status: :created, location: @article_version }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /article_versions/1 or /article_versions/1.json
  def update
    binding.pry
    respond_to do |format|
      if @article_version.update(article_version_params)
        # format.html { redirect_to article_version_url(@article_version), notice: "Article version was successfully updated." }
        format.html { redirect_to article_version_path(ownername: @article_version.article.ownerable.ownername,
                                                       id: @article_version.slug),
                                  notice: "Article version was successfully updated." }

        format.json { render :show, status: :ok, location: @article_version }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /article_versions/1 or /article_versions/1.json
  def destroy
    @article_version.destroy

    respond_to do |format|
      format.html { redirect_to article_versions_url, notice: "Article version was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_article
    @article = Articles::Article.find(params[:article_id])
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_article_version
      binding.pry
      @article_version = Articles::ArticleVersion.friendly.find(params[:id])

      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the post_path, and we should do
      # a 301 redirect that uses the current friendly id.
      request_slug = params[:id]
      if request_slug != @article_version.slug
        return redirect_to article_version_path(ownername: @article_version.owner.ownername,
                                                id: @article_version.slug),
                           :status => :moved_permanently
      end
    end

    # Only allow a list of trusted parameters through.
    def article_version_params
      params.require(:articles_article_version).permit(:title, :solves_the_problem, :content, :sources,
                                                       :additional_information, :article_id)
    end
end
