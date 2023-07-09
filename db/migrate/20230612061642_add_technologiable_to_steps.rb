class AddTechnologiableToSteps < ActiveRecord::Migration[7.0]
  def change
    add_reference :steps, :technologiable, polymorphic: true, null: true, index: true
  end
end
