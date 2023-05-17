class SimpleClasses::SimpleClass < ApplicationRecord

  searchkick callbacks: :async, text_middle: [:title, :description]


  belongs_to :folder, class_name: "Folder"
  # has_many :folders, class_name: "SimpleObjects::Folder", dependent: :destroy


  # has_many :class_container_simple_class
  # has_many :class_containers, through: :class_container_simple_class, class_name: "SimpleClasses::ClassContainer"
  # accepts_nested_attributes_for :class_containers

  belongs_to :instructionable, polymorphic: true, optional: true

  self.inheritance_column = nil

  has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup", dependent: :destroy
  accepts_nested_attributes_for :interface_groups


  has_many :class_containers, class_name: "SimpleClasses::ClassContainer", dependent: :destroy
  accepts_nested_attributes_for :class_containers

  # has_many :sub_containers, class_name: "SimpleClasses::ClassContainer", foreign_key: :simple_class_id
  # accepts_nested_attributes_for :sub_containers

  def root_class_container
    self.class_containers.where(parent_id: nil).first
  end

  def root_interface_group
    self.interface_groups.where(parent_id: nil).first
  end

end
