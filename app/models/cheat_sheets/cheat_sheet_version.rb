class CheatSheets::CheatSheetVersion < ApplicationRecord
  include Unitable
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :cheat_sheet
  has_many :notes
  accepts_nested_attributes_for :notes, allow_destroy: true

  validates :title, presence: true, allow_blank: false

  alias_method :whole_unit, :cheat_sheet


  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
