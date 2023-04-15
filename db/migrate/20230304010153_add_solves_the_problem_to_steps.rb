class AddSolvesTheProblemToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :solves_the_problem, :text
  end
end
