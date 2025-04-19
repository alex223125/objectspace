require 'active_support/concern'

module Commentable
  extend ActiveSupport::Concern

  COMMENTABLE_MAPPING = [
    { controller: "unit/unit_versions", class: Units::UnitVersion },
    { controller: "improvements", class: Improvements::Improvement },
    { controller: "shared_class_layer/interface_members", class: "one_of_technology_classes_as_interface_member" },
    { controller: "shared_class_layer/container_members", class: "one_of_technology_classes_as_container_member" }
  ].freeze

  INTERFACE_MEMBER_CASE = "one_of_technology_classes_as_interface_member".freeze
  CONTAINER_MEMBER_CASE = "one_of_technology_classes_as_container_member".freeze

  VERSIONABLE_TECHNOLOGIES = [Articles::Article, Units::Unit, Algorithms::Algorithm,
                              CheatSheets::CheatSheet, CheatSheetGroups::CheatSheetGroup]

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
      binding.pry
      interface_member = SimpleClasses::InterfaceMember.friendly.try(:find, params[:id])
      interface_member.memberable.default_version
    elsif commentable[:class] == CONTAINER_MEMBER_CASE
      binding.pry
      container_member = SimpleClasses::ContainerMember.friendly.try(:find, params[:id])
      memberable = container_member.memberable
      if versionable_technology?(memberable)
        memberable.default_version
      elsif memberable.class == SimpleClasses::SimpleClass
        memberable
      end
    else
      commentable[:class].find(params[:id])
    end
  end

  def versionable_technology?(technology)
    VERSIONABLE_TECHNOLOGIES.include?(technology.class)
  end

end