class Algorithms::Algorithm < ApplicationRecord

  # searchkick text_middle: %i[title source_page_description]

  validates :title, presence: true, allow_blank: false

  # has_many :units, -> { order(position: :asc) }
  # accepts_nested_attributes_for :units, reject_if: :all_blank, allow_destroy: true

  has_many :algorithm_versions, dependent: :destroy, class_name: "Algorithms::AlgorithmVersion"
  accepts_nested_attributes_for :algorithm_versions

  # has_many :steps, as: :algorithmic_steps, through: :algorithm_versions, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  # has_many :substeps

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

end
