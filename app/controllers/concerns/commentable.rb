require 'active_support/concern'

module Commentable
  extend ActiveSupport::Concern

  COMMENTABLE_MAPPING = [ { controller: "unit/unit_versions", class: Units::UnitVersion } ]

  included do
    before_action :comments, only: [:show]
  end

  def comments
    @commentable = find_commentable
    binding.pry
    @comments = @commentable.comments.order("created_at desc")
    @comment = Comment.new
  end

  private

  def find_commentable
    binding.pry
    commentable = COMMENTABLE_MAPPING.find {|commentable| commentable[:controller] == params[:controller] }
    commentable[:class].find(params[:id])
  end
end