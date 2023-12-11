class CommentsController < ApplicationController

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
      redirect_to :back
    else
      flash[:error] = "Error adding comment."
    end
  end

  private

  def find_commentable
    binding.pry
    params[:commentable_type].constantize.find_by_id(params[:commentable_id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id, :user_id)
  end
end