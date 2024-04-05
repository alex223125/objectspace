class SimpleClasses::SimpleClass < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_start: [:title, :description],
             text_middle: [:title, :description],
             text_end: [:title, :description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  belongs_to :ownerable, polymorphic: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true
  # has_many :folders, class_name: "SimpleObjects::Folder", dependent: :destroy


  # has_many :class_container_simple_class
  # has_many :class_containers, through: :class_container_simple_class, class_name: "SimpleClasses::ClassContainer"
  # accepts_nested_attributes_for :class_containers

  belongs_to :instructionable, polymorphic: true, optional: true

  # self.inheritance_column = nil

  has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup", dependent: :destroy
  accepts_nested_attributes_for :interface_groups, allow_destroy: true


  has_many :class_containers, class_name: "SimpleClasses::ClassContainer", dependent: :destroy
  accepts_nested_attributes_for :class_containers, allow_destroy: true

  # has_many :sub_containers, class_name: "SimpleClasses::ClassContainer", foreign_key: :simple_class_id
  # accepts_nested_attributes_for :sub_containers

  has_many :simple_class_attributes
  accepts_nested_attributes_for :simple_class_attributes, allow_destroy: true

  has_many :interface_members, through: :interface_groups, class_name: "SimpleClasses::InterfaceMember"

  has_many :included_class_containers, class_name: "SimpleClasses::ClassContainer", foreign_key: :related_simple_class_id
  has_many :included_interface_groups, class_name: "SimpleClasses::InterfaceGroup", foreign_key: :related_simple_class_id

  validates :title, :description, :functional_type, presence: true, allow_blank: false

  def root_class_container
    self.class_containers.where(parent_id: nil).first
  end

  # TODO: ADD CHECK BY TYPE - InterfaceGroups::FunctionalTypes[:root]
  def root_interface_group
    self.interface_groups.where(parent_id: nil).first
  end

  def root_interface_groups
    self.interface_groups.where(parent_id: nil)
  end

  def owner
    self.ownerable
  end

  def search_data
    {
      title: title,
      description: description,
      list_of_tags: tag_list,
      ownerable_id: ownerable_id,
      folder_id: folder_id,
      repository_id: repository_id
    }
  end

  def functional_type_value
    SimpleClasses::FunctionalTypes[self.functional_type]
  end

  def functional_type_readable_name
    binding.pry
    type = self.functional_type_value
    SimpleClasses::FunctionalTypes.meta(type)[:readable_name]
  end

  def decision_process_object_class?
    self.functional_type == SimpleClasses::FunctionalTypes[:decision_process_object_class]
  end

  def decision_object_container_class?
    self.functional_type == SimpleClasses::FunctionalTypes[:decision_object_container_class]
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
