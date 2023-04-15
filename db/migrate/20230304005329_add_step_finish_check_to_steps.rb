class AddStepFinishCheckToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :step_finish_check, :text
  end
end
