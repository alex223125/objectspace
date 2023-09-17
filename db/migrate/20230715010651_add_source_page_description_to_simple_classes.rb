class AddSourcePageDescriptionToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :source_page_description, :text
  end
end
