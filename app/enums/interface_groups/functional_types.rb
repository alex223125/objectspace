module InterfaceGroups
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :root
    value :id => 2, :name => :regular
    value :id => 3, :name => :class_container_root
  end
end

