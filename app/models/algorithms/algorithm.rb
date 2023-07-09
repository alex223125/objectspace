class Algorithms::Algorithm < ApplicationRecord
  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_middle: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  belongs_to :folder, class_name: "Folder"
  belongs_to :ownerable, polymorphic: true

  # open question: should it be has_one or allow has_many for DPO ?
  has_many :simple_classes, as: :instructionable, class_name: "SimpleClasses::SimpleClass"

  # has_many :units, -> { order(position: :asc) }
  # accepts_nested_attributes_for :units, reject_if: :all_blank, allow_destroy: true

  has_many :algorithm_versions, dependent: :destroy, class_name: "Algorithms::AlgorithmVersion"
  accepts_nested_attributes_for :algorithm_versions

  # has_many :steps, as: :algorithmic_steps, through: :algorithm_versions, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  # has_many :substeps

  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"


  validates :title, presence: true, allow_blank: false
  validates_with Algorithms::SizeOfStepsValidator, on: [:create]


    include PgSearch::Model
  pg_search_scope :english_global_search,
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
    Algorithms::AlgorithmVersion.find_by(id: self.default_version_id)
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
