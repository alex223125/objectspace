class Repository < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  acts_as_taggable_on :tags

  # belongs_to :user
  belongs_to :ownerable, polymorphic: true

  has_many :folders, dependent: :destroy

  has_many :articles, class_name: "Articles::Article"
  has_many :units, class_name: "Units::Unit"
  has_many :algorithms, class_name: "Algorithms::Algorithm"
  has_many :cheat_sheets, class_name: "CheatSheets::CheatSheet", dependent: :destroy
  has_many :simple_classes, class_name: "SimpleClasses::SimpleClass"
  has_many :frameworks, class_name: "Frameworks::Framework"

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
