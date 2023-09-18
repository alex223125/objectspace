class SimpleClasses::InterfaceMember < ApplicationRecord

  belongs_to :interface_group
  belongs_to :memberable, polymorphic: true
  has_one :simple_class, :through => :interface_group, class_name: "SimpleClasses::SimpleClass"

  # TODO: validate that member type or Unit or Algorithm
  # we accept only these 2 types of units as interface members

  has_many :actions_simple_class_attributes, dependent: :destroy, foreign_key: "action_id"
  has_many :simple_class_attributes, through: :actions_simple_class_attributes, class_name: "SimpleClasses::SimpleClassAttribute"


end
