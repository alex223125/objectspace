class Algorithms::AlgorithmVersion < ApplicationRecord

  belongs_to :algorithm

  has_many :control_structures, class_name: "Algorithms::ControlStructure"
  accepts_nested_attributes_for :control_structures

  # has_many :steps, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  has_many :substeps, as: :substepable
  has_many :simple_classes, as: :instructionable, class_name: "SimpleClasses::SimpleClass"


  validates :control_structures, presence: { message: "Algorithm should have at least 1 step" }


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

end