module SimpleClasses
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :decision_process_object_class, :readable_name => 'Decision process object class'
    value :id => 2, :name => :decision_object_class, :readable_name => 'Decision object class'
    value :id => 3, :name => :decision_object_container_class, :readable_name => 'Decision object container class'
  end
end