class AddUuidToIntroductionSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :introduction_steps, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
