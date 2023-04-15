class AddAlgorithmIdToSubsteps < ActiveRecord::Migration[7.0]
  def change
    add_column :substeps, :algorithm_id, :integer
  end
end
