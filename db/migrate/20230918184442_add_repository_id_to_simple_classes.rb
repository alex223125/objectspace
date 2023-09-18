class AddRepositoryIdToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :repository_id, :integer
  end
end
