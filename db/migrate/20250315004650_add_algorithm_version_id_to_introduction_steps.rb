class AddAlgorithmVersionIdToIntroductionSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :introduction_steps, :algorithm_version_id, :integer
  end
end
