class AddIndexesToSupportMessages < ActiveRecord::Migration[7.0]
  def change
    add_index :support_messages, :email_confirmation_token, unique: true
    add_index :support_messages, :email_confirmed_at
    add_index :support_messages, :created_at
  end
end