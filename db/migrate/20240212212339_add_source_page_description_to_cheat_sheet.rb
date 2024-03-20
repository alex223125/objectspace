class AddSourcePageDescriptionToCheatSheet < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheets, :source_page_description, :text
  end
end
