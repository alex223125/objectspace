class AddSourcesToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :sources, :text
  end
end
