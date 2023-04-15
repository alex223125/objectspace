class AddSolvesTheProblemToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :solves_the_problem, :text
  end
end
