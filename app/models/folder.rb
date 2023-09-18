class Folder < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  searchkick callbacks: :async, text_middle: [:title, :description]

  has_closure_tree
  # belongs_to :simple_object, class_name: "SimpleObjects::SimpleObject"

  # belongs_to :user
  # TODO: check that it has parent or repository, not both, not nothing
  belongs_to :repository, optional: true

  has_many :subfolders,
           class_name: "Folder",
           foreign_key: "parent_id"
  accepts_nested_attributes_for :subfolders


  has_many :articles, class_name: "Articles::Article"
  accepts_nested_attributes_for :articles

  has_many :units, class_name: "Units::Unit"
  has_many :algorithms, class_name: "Algorithms::Algorithm"
  has_many :simple_classes, class_name: "SimpleClasses::SimpleClass"
  has_many :frameworks, class_name: "Frameworks::Framework"


  # def folders_tree_without_root
  #   self_and_ancestors.where.not(parent_id: nil)
  # end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end
