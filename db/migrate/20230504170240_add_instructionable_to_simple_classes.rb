class AddInstructionableToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_reference :simple_classes, :instructionable, polymorphic: true, index: true
  end
end
