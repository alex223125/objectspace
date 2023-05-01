class AddSourcePageDescriptionToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :source_page_description, :text
  end
end
