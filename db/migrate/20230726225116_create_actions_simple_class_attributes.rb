class CreateActionsSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :actions_simple_class_attributes do |t|
      t.references :action, null: false, foreign_key: {to_table: :interface_members}, index: true,
                   index: { name: 'index_actions_attributes_on_action_id' }
      t.references :simple_class_attribute, null: false, foreign_key: {to_table: :simple_class_attributes}, index: true,
                   index: { name: 'index_actions_attributes_on_simple_class_attribute_id' }

      t.timestamps
    end
  end
end
