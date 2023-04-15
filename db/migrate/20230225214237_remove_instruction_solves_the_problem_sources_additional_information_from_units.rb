class RemoveInstructionSolvesTheProblemSourcesAdditionalInformationFromUnits < ActiveRecord::Migration[7.0]
  def change
    remove_column :units, :instruction, :text
    remove_column :units, :solves_the_problem, :text
    remove_column :units, :sources, :text
    remove_column :units, :additional_information, :text
  end
end
