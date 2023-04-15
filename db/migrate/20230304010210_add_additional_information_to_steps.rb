class AddAdditionalInformationToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :additional_information, :text
  end
end
