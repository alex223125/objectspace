class CreateSupportMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :support_messages do |t|
      t.string :first_name
      t.string :last_name
      t.string :organization_name
      t.string :support_category
      t.string :referral_source
      t.text :message
      t.string :email
      t.string :email_confirmation_token
      t.datetime :email_confirmed_at
      t.datetime :human_verified_at
      t.string :ip_address
      t.text :user_agent

      t.timestamps
    end
  end
end
