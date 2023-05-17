class SimpleClasses::InterfaceGroup < ApplicationRecord

  has_closure_tree
  has_closure_tree_root :root_class_group

  has_many :groups,
           class_name: "SimpleClasses::InterfaceGroup",
           foreign_key: "parent_id"
  accepts_nested_attributes_for :groups

  # add validation that it's connected to at least one of these SmpleClass or framework
  belongs_to :simple_class, class_name: "SimpleClasses::SimpleClass", optional: true
  # acts_as_list scope: :simple_class
  belongs_to :framework, class_name: "Frameworks::Framework", optional: true

  has_many :interface_members, class_name: "SimpleClasses::InterfaceMember", dependent: :destroy
  accepts_nested_attributes_for :interface_members



end
