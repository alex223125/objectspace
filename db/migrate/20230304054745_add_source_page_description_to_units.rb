class AddSourcePageDescriptionToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :source_page_description, :text
  end
end
