class SimpleClasses::InterfaceMember < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  default_scope { order(position: :asc) }

  belongs_to :interface_group
  belongs_to :memberable, polymorphic: true
  # has_one :simple_class, :through => :interface_group, class_name: "SimpleClasses::SimpleClass"

  # TODO: validate member type or Unit or Algorithm or other technologies

  has_many :actions_simple_class_attributes, dependent: :destroy, foreign_key: "action_id"
  has_many :simple_class_attributes, through: :actions_simple_class_attributes, class_name: "SimpleClasses::SimpleClassAttribute"

  def simple_class
    self.interface_group.related_simple_class || self.interface_group.simple_class
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
