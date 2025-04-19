class CheatSheets::CheatSheet < ApplicationRecord
  include Sourceable

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_start: [:title, :source_page_description],
             text_middle: [:title, :source_page_description],
             text_end: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  ####
  # TODO: validate that its in repository or in folder, or in container member of in interface
  # member
  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true

  has_many :container_members, as: :memberable, class_name: "SimpleClasses::ContainerMember"
  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"
  ####

  belongs_to :ownerable, polymorphic: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  belongs_to :default_version, foreign_key: "default_version_id", class_name: "CheatSheets::CheatSheetVersion"

  has_many :cheat_sheet_versions, dependent: :destroy
  accepts_nested_attributes_for :cheat_sheet_versions

  has_many :sections, as: :sectionable, class_name: "CheatSheetGroups::Section"

  has_many :permissions, as: :permissionable, class_name: "Permission"

  def class_key
    "cheat_sheet"
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

end
