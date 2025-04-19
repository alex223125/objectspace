class Frameworks::Framework < ApplicationRecord

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

  # DONT REMOVE, MAYBE WE WILL HAVE INTERFACE GROUPS FOR FRAMEWORKS IN FUTURE ITERATIONS
  # has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup", dependent: :destroy
  # accepts_nested_attributes_for :interface_groups, allow_destroy: true

  has_one :framework_interface, class_name: "Frameworks::FrameworkInterface", dependent: :destroy

  has_many :class_containers, class_name: "SimpleClasses::ClassContainer", dependent: :destroy
  accepts_nested_attributes_for :class_containers, allow_destroy: true

  has_many :permissions, as: :permissionable, class_name: "Permission"

  has_many :included_class_containers, class_name: "SimpleClasses::ClassContainer", foreign_key: :related_framework_id
  has_many :included_interface_groups, class_name: "SimpleClasses::InterfaceGroup", foreign_key: :related_framework_id
  has_many :included_simple_classes, class_name: "SimpleClasses::SimpleClass", foreign_key: :related_framework_id

  has_many :framework_folders, class_name: "Frameworks::FrameworkFolder", dependent: :destroy
  accepts_nested_attributes_for :framework_folders, allow_destroy: true

  # TODO:
  #     add validation that only one record with parent_id:nil should exists
  def root_framework_folder
    self.framework_folders.where(parent_id: nil).first
  end

  # TODO: move to concern for framework and simple_Class
  # # TODO: ADD CHECK BY TYPE - same as InterfaceGroups::FunctionalTypes[:root]
  def root_class_container
    self.class_containers.where(parent_id: nil).first
  end

  # TODO: ADD CHECK BY TYPE - InterfaceGroups::FunctionalTypes[:root]
  def root_interface_group
    self.interface_groups.where(parent_id: nil).first
  end

  def owner
    self.ownerable
  end

  def location
    self.folder || self.repository
  end

  private

  # doc: mapping for searchkick
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

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
