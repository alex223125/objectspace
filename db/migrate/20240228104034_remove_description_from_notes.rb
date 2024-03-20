class RemoveDescriptionFromNotes < ActiveRecord::Migration[7.0]
  def change
    remove_column :notes, :description, :text
  end
end
