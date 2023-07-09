class Users::UsersController < ApplicationController
  # before_action :set_article, only: %i[ show edit update destroy preview ]

  # GET /articles or /articles.json
  def index
    @users = User.all
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  def suggestions

    query = params[:keyword]


    @users = Searchkick.search(query, models: User, fields: [:name, :username])


    respond_to do |format|
      format.json {
        render json: @users, status: :ok, each_serializer: Users::UserSuggestionSerializer
      }
    end
    # render json: chatrooms, status: :ok, each_serializer: ChatroomShowSerializer
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_article
  #   @article = Articles::Article.find(params[:id])
  # end
  #
  # # Only allow a list of trusted parameters through.
  # def article_params
  #   params.require(:articles_article).permit(:title, :default_version_id, :visibility_status, :source_page_description,
  #                                            article_versions_attributes: [:title, :solves_the_problem, :content,
  #                                                                          :sources, :additional_information])
  # end
end
