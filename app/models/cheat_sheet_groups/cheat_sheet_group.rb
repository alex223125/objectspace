class CheatSheetGroups::CheatSheetGroup < ApplicationRecord

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_start: [:title, :source_page_description],
             text_middle: [:title, :source_page_description],
             text_end: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags


  # TODO: validate that its in repository or in folder, not in both and not without at leas one of them
  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :ownerable, polymorphic: true
  belongs_to :default_version, foreign_key: "default_version_id", class_name: "CheatSheetGroups::CheatSheetGroupVersion"

  has_many :cheat_sheet_group_versions
  accepts_nested_attributes_for :cheat_sheet_group_versions

  has_many :sections, as: :sectionable, class_name: "CheatSheetGroups::Section"

  has_many :container_members, as: :memberable, class_name: "SimpleClasses::ContainerMember"
  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"

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
