class AddTechnologiableToNodes < ActiveRecord::Migration[7.0]
  def change
    add_reference :nodes, :technologiable, polymorphic: true, null: true, index: true
  end
end