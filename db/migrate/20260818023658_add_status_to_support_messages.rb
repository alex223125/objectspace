class AddStatusToSupportMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :support_messages,
               :status,
               :string,
               null: false,
               default: "pending_confirmation"

    add_index :support_messages, :status
  end
end