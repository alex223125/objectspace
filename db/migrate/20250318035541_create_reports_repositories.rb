class CreateReportsRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :reports_repositories do |t|

      t.timestamps
    end
  end
end
