class CommentsController < ApplicationController

  def list
    binding.pry
    commentable = find_commentable

    binding.pry
    comments = commentable.comments

    binding.pry
    scenario = params[:scenario]

    binding.pry
    pagy, comments = pagy(comments, page: params[:page], items: 3 )
    respond_to do |format|
      format.json {
        render json: { entries: render_to_string(partial: "comments/comments_list",
          formats: [:html],
          locals: {comments: comments, scenario: scenario}) }
      }
    end
  end

  def new
    binding.pry
    @parent_id = params.delete(:parent_id)
    @commentable = find_commentable
    @comment = Comment.new(:parent_id => @parent_id,
      :commentable_id => @commentable.id,
      :commentable_type => @commentable.class.to_s)
  end

  def create
    binding.pry
    @commentable = find_commentable

    binding.pry
    @comment = @commentable.comments.build(comment_params)
    if @comment.save
      flash[:notice] = "Successfully created comment."
      # redirect_to @commentable
      redirect_back(fallback_location: root_path)
    else
      flash[:error] = "Error adding comment."
    end
  end

  private

  def find_commentable
    binding.pry
    if UUID.validate(params[:commentable_id])
      params[:commentable_type].constantize.find_by_uuid(params[:commentable_id])
    else
      params[:commentable_type].constantize.find_by_id(params[:commentable_id])
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id, :user_id, :commentable_type, :commentable_id)
  end
end