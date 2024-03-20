class Comment < ApplicationRecord
  has_closure_tree
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  alias_attribute :comments, :children
end
