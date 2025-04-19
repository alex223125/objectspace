class CreateAlgorithmTrees < ActiveRecord::Migration[7.0]
  def change
    create_table :algorithm_trees do |t|
      t.string :algorithm_version_title

      t.timestamps
    end
  end
end
