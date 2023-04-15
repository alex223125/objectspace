class AddSourcesToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :sources, :text
  end
end
