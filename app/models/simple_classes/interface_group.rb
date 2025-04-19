class SimpleClasses::InterfaceGroup < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  has_closure_tree order: 'position', numeric_order: true
  has_closure_tree_root :root_class_group

  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  # TODO: Add valudation that one of these is present
  belongs_to :related_simple_class, class_name: "SimpleClasses::SimpleClass", foreign_key: :related_simple_class_id, optional: true
  belongs_to :related_class_container, class_name: "SimpleClasses::ClassContainer", foreign_key: :related_class_container_id, optional: true
  belongs_to :related_framework, class_name: "Frameworks::Framework", foreign_key: :related_framework_id, optional: true



  # TODO: add validation that it's connected to at least one of these SmpleClass or framework
  belongs_to :class_container, class_name: "SimpleClasses::ClassContainer", optional: true
  belongs_to :simple_class, class_name: "SimpleClasses::SimpleClass", optional: true
  # acts_as_list scope: :simple_class
  belongs_to :framework, class_name: "Frameworks::Framework", optional: true


  has_many :groups,
           class_name: "SimpleClasses::InterfaceGroup",
           foreign_key: "parent_id",
           dependent: :destroy

  accepts_nested_attributes_for :groups, allow_destroy: true
  # -> { order 'interface_groups.position ASC' },

  has_many :interface_members, class_name: "SimpleClasses::InterfaceMember", dependent: :destroy
  accepts_nested_attributes_for :interface_members, allow_destroy: true

  validates :title, :functional_type, presence: true, allow_blank: false

  def root_functional_type?
    self.functional_type == InterfaceGroups::FunctionalTypes[:root]
  end

  def regular_functional_type?
    self.functional_type == InterfaceGroups::FunctionalTypes[:regular]
  end

  def class_container_root_functional_type?
    self.functional_type == InterfaceGroups::FunctionalTypes[:class_container_root]
  end

  def content_present?
    if self.root?
      self.interface_members.any?
    else
      self.interface_members.any? || self.groups.any?
    end
  end

  def closest_simple_class
    self.simple_class || self.related_simple_class
  end

  def closest_framework
    self.framework || self.related_framework
  end

  def related_class_layer_entity
    self.related_simple_class || self.related_framework
  end

  def class_layer_entity
    self.simple_class || self.framework
  end

  def closest_class_layer_entity
    self.related_class_layer_entity || self.class_layer_entity
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end
end
