module Improvements
  class ActiveStatusTypes < ActiveEnum::Base
    value :id => 1, :name => :open
    value :id => 2, :name => :closed
  end
end
