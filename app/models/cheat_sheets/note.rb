class CheatSheets::Note < ApplicationRecord
  belongs_to :cheat_sheet_version

  has_many :link_attachments, class_name: "LinkAttachment"
  accepts_nested_attributes_for :link_attachments, allow_destroy: true

  def class_key
    "note"
  end

  def uniq_key
    class_key + self.uuid
  end

end
