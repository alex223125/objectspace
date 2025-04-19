class CreateFrameworkMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :framework_members do |t|
      t.string :title

      t.timestamps
    end
  end
end
