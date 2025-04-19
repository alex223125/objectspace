class AddSlugToLoggingIntroductionSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_introduction_steps, :slug, :string
    add_index :logging_introduction_steps, :slug, unique: true
  end
end
