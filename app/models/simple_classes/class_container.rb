class SimpleClasses::ClassContainer < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  has_closure_tree
  has_closure_tree_root :root_class_container

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :related_simple_class, class_name: "SimpleClasses::SimpleClass", foreign_key: :related_simple_class_id

  # belongs_to :parent_container,
  #            class_name: "SimpleClasses::ClassContainer",
  #            foreign_key: "parent_id", optional: true

  has_many :containers,
           class_name: "SimpleClasses::ClassContainer",
           foreign_key: "parent_id"
  accepts_nested_attributes_for :containers

  has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup"

  # Technologies:
  # has_many :articles, class_name: "Articles::Article"

  # has_many :class_container_simple_class
  # has_many :simple_classes, through: :class_container_simple_class
  # accepts_nested_attributes_for :simple_classes

  # def items_attributes=(attributes)
  #   self.item_ids = attributes.values.map { |item| item['id'] }
  #   super(attributes)
  # end
  # def simple_classes_attributes=(attributes)
  #   self.simple_class_ids = attributes.values.map { |simple_class| simple_class['id'] }
  #   super(attributes)
  # end


  # добавить проекру что бы рут точно имел симпл класс или фреймворк
  # добавить сервис который ставит для каждой группы айдишник фреймворка или симпл класса для флексибилити
  belongs_to :simple_class, optional: true
  belongs_to :framework, class_name: "Frameworks::Framework", optional: true

  has_many :container_members, class_name: "SimpleClasses::ContainerMember", dependent: :destroy
  accepts_nested_attributes_for :container_members

  has_many :included_interface_groups, class_name: "SimpleClasses::InterfaceGroup", foreign_key: :related_class_container_id

  def root_functional_type?
    self.functional_type == ClassContainers::FunctionalTypes[:root_class_container]
  end

  def regular_functional_type?
    self.functional_type == ClassContainers::FunctionalTypes[:regular]
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
