class AddSlugToIntroductionSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :introduction_steps, :slug, :string
    add_index :introduction_steps, :slug, unique: true
  end
end

