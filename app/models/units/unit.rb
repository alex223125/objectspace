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

  belongs_to :folder, class_name: "Folder"

  has_many :unit_versions, dependent: :destroy, class_name: "Units::UnitVersion"
  accepts_nested_attributes_for :unit_versions

  has_many :unit_usage_examples, dependent: :destroy, class_name: "UnitUsageExample"
  accepts_nested_attributes_for :unit_usage_examples

  has_many :improvements

  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"




  validates :title, presence: true, allow_blank: false

  # has_many :substeps, class_name: "Algorithms::Substep"


  include PgSearch::Model
  pg_search_scope :english_unit_search,
                  against: {
                    title: 'A',
                    source_page_description: 'B'
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable',
                      any_word: true,
                      prefix: true
                    }
                  }



  def default_version
    Units::UnitVersion.find_by(id: self.default_version_id)
  end

  def search_data
    {
      title: title,
      source_page_description: source_page_description,
      list_of_tags: tag_list,
      ownerable_id: ownerable_id
    }
  end

end
