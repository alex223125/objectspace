class Algorithms::AlgorithmVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]


  belongs_to :algorithm

  has_many :control_structures, class_name: "Algorithms::ControlStructure"
  accepts_nested_attributes_for :control_structures

  # has_many :steps, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  has_many :substeps, as: :substepable

  validates :control_structures, presence: { message: "Algorithm should have at least 1 step" }

  validates :title, presence: true

  include PgSearch::Model
  pg_search_scope :english_global_search,
                  against: {
                    title: 'A',
                    solves_the_problem: 'B',
                    sources: 'C',
                    additional_information: 'D'
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable',
                      any_word: true,
                      prefix: true
                    }
                  }

  alias_method :whole_unit, :algorithm

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end