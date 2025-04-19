# TODO: move to simple_class_attribute namespace
class SimpleClasses::ActionsSimpleClassAttribute < ApplicationRecord
  belongs_to :action, class_name: "SimpleClasses::InterfaceMember"
  belongs_to :simple_class_attribute, class_name: "SimpleClasses::SimpleClassAttribute"
end
