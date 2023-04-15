class AddAdditionalInformationToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :additional_information, :text
  end
end
