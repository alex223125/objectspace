module ClassContainers
  class BelongsToStructureTypes < ActiveEnum::Base
    value :id => 1, :name => :belongs_to_simple_class
    value :id => 2, :name => :belongs_to_framework
  end
end