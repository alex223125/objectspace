class Units::Unit < ApplicationRecord

  extend Pagy::Searchkick

  searchkick callbacks: :async,
             text_middle: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  acts_as_taggable_on :tags
  scope :search_import, -> { includes(:tags) }

  # belongs_to :algorithm, optional: true
  # acts_as_list scope: :algorithm

  belongs_to :ownerable, polymorphic: true

  # TODO: add validation unit should be in folder or in repositry, not 2 places at the same time
  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true

  has_many :unit_versions, dependent: :destroy, class_name: "Units::UnitVersion"
  accepts_nested_attributes_for :unit_versions

  has_many :usage_examples, through: :unit_versions, dependent: :destroy, class_name: "UsageExample"
  accepts_nested_attributes_for :usage_examples, allow_destroy: true

  has_many :improvements

  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"




  validates :title, presence: true, allow_blank: false

  # has_many :substeps, class_name: "Algorithms::Substep"


  # include PgSearch::Model
  # pg_search_scope :english_unit_search,
  #                 against: {
  #                   title: 'A',
  #                   source_page_description: 'B'
  #                 },
  #                 using: {
  #                   tsearch: {
  #                     dictionary: 'english',
  #                     tsvector_column: 'searchable',
  #                     any_word: true,
  #                     prefix: true
  #                   }
  #                 }



  def default_version
    Units::UnitVersion.find_by(id: self.default_version_id)
  end

  def class_key
    "unit"
  end

  def uniq_key
    class_key + self.uuid
  end

  private

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
