class CreateClassContainerSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :class_container_simple_classes do |t|
      t.references :class_container, null: false, foreign_key: true
      t.references :simple_class, null: false, foreign_key: true

      t.timestamps
    end
  end
end
