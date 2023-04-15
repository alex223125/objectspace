class Units::Unit < ApplicationRecord

  searchkick text_middle: %i[title source_page_description]


  # belongs_to :algorithm, optional: true
  # acts_as_list scope: :algorithm

  validates :title, presence: true, allow_blank: false

  has_many :unit_versions, dependent: :destroy, class_name: "Units::UnitVersion"
  accepts_nested_attributes_for :unit_versions

  has_many :unit_usage_examples, dependent: :destroy, class_name: "UnitUsageExample"
  accepts_nested_attributes_for :unit_usage_examples

  has_many :improvements


  has_many :substeps, class_name: "Algorithms::Substep"


  include PgSearch::Model
  pg_search_scope :global_search,
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

end
