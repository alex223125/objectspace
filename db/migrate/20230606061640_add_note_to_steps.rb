class AddNoteToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :note, :text
  end
end
