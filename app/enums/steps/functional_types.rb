module Steps
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :regular
    value :id => 2, :name => :wrapper
    value :id => 3, :name => :container
  end
end