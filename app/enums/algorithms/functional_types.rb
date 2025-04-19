module Algorithms
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :regular
    value :id => 2, :name => :class_level
    value :id => 3, :name => :framework_level
  end
end