class Units::Unit < ApplicationRecord
  include Sourceable
  include Improvable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick

  searchkick callbacks: :async,
             text_start: [:title, :source_page_description],
             text_middle: [:title, :source_page_description],
             text_end: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  acts_as_taggable_on :tags
  scope :search_import, -> { includes(:tags) }

  # belongs_to :algorithm, optional: true
  # acts_as_list scope: :algorithm

  belongs_to :ownerable, polymorphic: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  # TODO: add validation unit should be in folder or in repositry, not 2 places at the same time
  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true

  has_many :unit_versions, dependent: :destroy, class_name: "Units::UnitVersion"
  accepts_nested_attributes_for :unit_versions

  has_many :unit_version_usage_examples, through: :unit_versions, class_name: "UsageExamples::UnitVersionUsageExample"
  has_many :usage_examples, through: :unit_version_usage_examples, class_name: "UsageExamples::UsageExample"

  # accepts_nested_attributes_for :usage_examples, allow_destroy: true
  # has_many :improvements, through: :unit_versions, class_name: "Improvements::Improvement"

  has_many :link_attachments, as: :linkable, class_name: "CheatSheets::LinkAttachment"

  has_many :container_members, as: :memberable, class_name: "SimpleClasses::ContainerMember"
  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"

  has_many :sections, as: :sectionable, class_name: "CheatSheetGroups::Section"

  has_many :permissions, as: :permissionable, class_name: "Permission"

  validates :title, presence: true, allow_blank: false


  def default_version
    Units::UnitVersion.find_by(id: self.default_version_id)
  end

  def class_key
    "unit"
  end

  def uniq_key
    class_key + self.uuid
  end

  def owner
    self.ownerable
  end

  private

  # doc: mapping for searchkick
  def search_data
    {
      title: title,
      source_page_description: source_page_description,
      list_of_tags: tag_list,
      ownerable_id: ownerable_id,
      folder_id: folder_id,
      repository_id: repository_id
    }
  end

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end
end
