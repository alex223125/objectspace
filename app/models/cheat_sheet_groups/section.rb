class CheatSheetGroups::Section < ApplicationRecord
  self.table_name = 'cheat_sheet_group_sections'

  belongs_to :cheat_sheet_group_version
  belongs_to :sectionable, polymorphic: true

  # Valid sectionable types
  # Articles
  # CheatSheets
  # CheatSheetGroups
end
