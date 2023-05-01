class CreateSubsteps < ActiveRecord::Migration[7.0]
  def change
    create_table :substeps do |t|
      t.string :title
      t.text :note
      t.integer :position
      t.integer :step_id

      t.references :substepable, polymorphic: true, null: false

      t.timestamps
    end
  end
end