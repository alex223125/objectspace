class Frameworks::Framework < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_middle: [:title, :description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  belongs_to :ownerable, polymorphic: true

  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true

  has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup", dependent: :destroy
  accepts_nested_attributes_for :interface_groups, allow_destroy: true

  has_many :class_containers, class_name: "SimpleClasses::ClassContainer", dependent: :destroy
  accepts_nested_attributes_for :class_containers, allow_destroy: true

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

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
