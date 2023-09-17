module InterfaceGroups
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :root
    value :id => 2, :name => :uncategorized
    value :id => 3, :name => :regular
  end
end