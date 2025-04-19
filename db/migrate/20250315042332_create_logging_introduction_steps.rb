class CreateLoggingIntroductionSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :logging_introduction_steps do |t|
      t.integer :introduction_step_id

      t.timestamps
    end
  end
end
