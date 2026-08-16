class Admin::ArticlesController < AdminController
  before_action :set_article, only: %i[show edit update destroy]

  # GET /admin/articles
  def index
    query = params[:q].presence || "*"

    sort_column = params[:sort].presence || "created_at"
    sort_direction = params[:direction].presence || "desc"

    # Whitelist sortable columns/directions to avoid unsafe dynamic sorting.
    allowed_sort_columns = %w[created_at updated_at title]
    allowed_sort_directions = %w[asc desc]

    sort_column = "created_at" unless allowed_sort_columns.include?(sort_column)
    sort_direction = "desc" unless allowed_sort_directions.include?(sort_direction)

    sort_options = {
      sort_column => sort_direction
    }

    where_conditions = {}

    where_conditions[:visibility_status] =
      params[:visibility_status].to_i if params[:visibility_status].present?

    where_conditions[:folder_id] =
      params[:folder_id].to_i if params[:folder_id].present?

    where_conditions[:repository_id] =
      params[:repository_id].to_i if params[:repository_id].present?

    where_conditions[:creator_id] =
      params[:creator_id].to_i if params[:creator_id].present?

    where_conditions[:ownerable_type] =
      params[:ownerable_type] if params[:ownerable_type].present?

    where_conditions[:ownerable_id] =
      params[:ownerable_id].to_i if params[:ownerable_id].present?

    # Date filters
    if params[:start_date].present? || params[:end_date].present?
      where_conditions[:created_at] = {}

      if params[:start_date].present?
        where_conditions[:created_at][:gte] =
          params[:start_date].to_date.beginning_of_day
      end

      if params[:end_date].present?
        where_conditions[:created_at][:lte] =
          params[:end_date].to_date.end_of_day
      end
    end

    begin
      @articles = Articles::Article.search(
        query,
        where: where_conditions,
        order: sort_options,
        page: params[:page],
        per_page: 20
      )

    rescue Faraday::ConnectionFailed, Searchkick::Error => e
      Rails.logger.error(
        "Elasticsearch is down! Falling back to database. Error: #{e.message}"
      )

      @articles = Articles::Article.all

      if params[:visibility_status].present?
        @articles = @articles.where(
          visibility_status: params[:visibility_status].to_i
        )
      end

      if params[:folder_id].present?
        @articles = @articles.where(folder_id: params[:folder_id].to_i)
      end

      if params[:repository_id].present?
        @articles = @articles.where(repository_id: params[:repository_id].to_i)
      end

      if params[:creator_id].present?
        @articles = @articles.where(creator_id: params[:creator_id].to_i)
      end

      if params[:ownerable_type].present?
        @articles = @articles.where(
          ownerable_type: params[:ownerable_type]
        )
      end

      if params[:ownerable_id].present?
        @articles = @articles.where(
          ownerable_id: params[:ownerable_id].to_i
        )
      end

      if params[:start_date].present?
        @articles = @articles.where(
          "created_at >= ?",
          params[:start_date].to_date.beginning_of_day
        )
      end

      if params[:end_date].present?
        @articles = @articles.where(
          "created_at <= ?",
          params[:end_date].to_date.end_of_day
        )
      end

      # Simple database text search fallback.
      if params[:q].present?
        search_term = "%#{params[:q]}%"

        @articles = @articles.where(
          "title ILIKE :query",
          query: search_term
        )
      end

      @articles = @articles
        .order(sort_column => sort_direction)
        .page(params[:page])
        .per(20)

      flash.now[:alert] =
        "Live search is currently offline. Showing database records."
    end
  end


  # GET /admin/articles/:id
  def show
  end


  # GET /admin/articles/new
  def new
    @article = Articles::Article.new
  end


  # POST /admin/articles
  def create
    @article = Articles::Article.new(article_params)

    if @article.save
      redirect_to admin_article_path(@article),
                  notice: "Article was successfully created."
    else
      flash.now[:alert] = "Unable to create article."
      render :new, status: :unprocessable_entity
    end
  end


  # GET /admin/articles/:id/edit
  def edit
  end


  # PATCH/PUT /admin/articles/:id
  def update
    if @article.update(article_params)
      redirect_to admin_article_path(@article),
                  notice: "Article was successfully updated."
    else
      flash.now[:alert] = "Unable to update article."
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /admin/articles/:id
  def destroy
    @article.destroy

    redirect_to admin_articles_path,
                notice: "Article was successfully deleted."
  end


  private


  def set_article
    @article = Articles::Article.find(params[:id])
  end


  def article_params
    params.require(:article).permit(
      :title,
      :visibility_status,
      :folder_id,
      :repository_id,
      :creator_id,
      :ownerable_type,
      :ownerable_id
    )
  end
end