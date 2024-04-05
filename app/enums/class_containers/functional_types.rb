module ClassContainers
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :root_class_container
    value :id => 2, :name => :regular
  end
end