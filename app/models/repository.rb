class Repository < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  acts_as_taggable_on :tags

  belongs_to :ownerable, polymorphic: true

  has_many :repository_folders, class_name: "Folder", dependent: :destroy

  has_many :articles, class_name: "Articles::Article", dependent: :destroy
  has_many :units, class_name: "Units::Unit", dependent: :destroy
  has_many :algorithms, class_name: "Algorithms::Algorithm", dependent: :destroy
  has_many :cheat_sheets, class_name: "CheatSheets::CheatSheet", dependent: :destroy
  has_many :simple_classes, class_name: "SimpleClasses::SimpleClass", dependent: :destroy
  has_many :frameworks, class_name: "Frameworks::Framework", dependent: :destroy

  def should_generate_new_friendly_id?
    true
  end

  private

  def slug_candidates
    [ :name,
      [:name, :uuid]
    ]
  end

end
