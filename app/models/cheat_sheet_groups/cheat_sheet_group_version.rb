class CheatSheetGroups::CheatSheetGroupVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :cheat_sheet_group
  has_many :sections
  accepts_nested_attributes_for :sections, allow_destroy: true

  validates :title, presence: true, allow_blank: false

  alias_method :whole_unit, :cheat_sheet_group

  def class_key
    "cheat_sheet_group_version"
  end

  def uniq_key
    class_key + self.uuid
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
