class SimpleClasses::SimpleClassAttribute < ApplicationRecord
  include SimpleClassable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  # TODO: validation or SimpleClass or ClassContainer and related_simple_class
  belongs_to :simple_class, optional: true
  belongs_to :class_container, optional: true
  belongs_to :related_simple_class, class_name: "SimpleClasses::SimpleClass",
             foreign_key: :related_simple_class_id, optional: true

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :ownerable, polymorphic: true

  has_many :actions_simple_class_attributes, dependent: :destroy
  has_many :actions, through: :actions_simple_class_attributes, class_name: "SimpleClasses::InterfaceMember"
  # accepts_nested_attributes_for :actions, allow_destroy: true
  accepts_nested_attributes_for :actions


  has_many :articles_simple_class_attributes, dependent: :destroy, class_name: "SimpleClasses::ArticlesSimpleClassAttribute"
  has_many :articles, through: :articles_simple_class_attributes, class_name: "Articles::Article"
  # accepts_nested_attributes_for :articles, allow_destroy: true
  accepts_nested_attributes_for :articles_simple_class_attributes, allow_destroy: true

  def class_key
    "simple_class_attribute"
  end

  def uniq_key
    class_key + self.uuid
  end

  private

  # TODO: change id on uuid
  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end