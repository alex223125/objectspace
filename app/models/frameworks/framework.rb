class Frameworks::Framework < ApplicationRecord

  searchkick callbacks: :async, text_middle: [:title, :description]

  belongs_to :folder, class_name: "Folder"

  has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup", dependent: :destroy
  accepts_nested_attributes_for :interface_groups

  has_many :class_containers, class_name: "SimpleClasses::ClassContainer", dependent: :destroy
  accepts_nested_attributes_for :class_containers

end
