class Comment < ApplicationRecord
  has_closure_tree
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  # has_many :comments, as: :commentable
end
