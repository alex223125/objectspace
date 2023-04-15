class Improvement < ApplicationRecord

  belongs_to :unit, class_name: "Units::Unit"

  has_many :unit_version_improvements
  has_many :unit_versions, through: :unit_version_improvements, class_name: "Units::UnitVersion"

  include PgSearch::Model
  pg_search_scope :global_search,
                  against: {
                    title: 'A',
                    content: 'B',
                    sources: 'C'
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable',
                      any_word: true,
                      prefix: true
                    }
                  }




  # class Job < ApplicationRecord
  #   include PgSearch::Model
  #   pg_search_scope :search_job,
  #                   against: { title: 'A', description: 'B' },
  #                   using: {
  #                     tsearch: {
  #                       dictionary: 'english', tsvector_column: 'searchable'
  #                     }
  #                   }
  # end

  # pg_search_scope :search_full_text, against: {
  #   title: 'A',
  #   subtitle: 'B',
  #   content: 'C'
  # }

  # pg_search_scope :album_search,
  #                 associated_against: { album: [:tag, :title] },
  #                 using: {
  #                   tsearch: {
  #                     dictionary: 'english',
  #                     tsvector_column: 'searchable',
  #                     any_word: true,
  #                     prefix: true
  #                   }
  #                 }

end
