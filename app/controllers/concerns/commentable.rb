require 'active_support/concern'

module Commentable
  extend ActiveSupport::Concern

  COMMENTABLE_MAPPING = [
    { controller: "unit/unit_versions", class: Units::UnitVersion },
    { controller: "improvements", class: Improvements::Improvement },
    { controller: "simple_class/interface_members", class: "one_of_technology_classes" }
  ].freeze

  INTERFACE_MEMBER_CASE = "one_of_technology_classes".freeze

  included do
    before_action :comments, only: [:show]
  end

  def comments
    @commentable = find_commentable
    binding.pry
    # @comments = @commentable.comments.order("created_at desc")
    @comment = Comment.new
  end

  private

  def find_commentable
    binding.pry
    commentable = COMMENTABLE_MAPPING.find {|commentable| commentable[:controller] == params[:controller] }
    if commentable[:class] == INTERFACE_MEMBER_CASE
      interface_member = SimpleClasses::InterfaceMember.friendly.try(:find, params[:id])
      interface_member.memberable.default_version
    else
      commentable[:class].find(params[:id])
    end
  end
end