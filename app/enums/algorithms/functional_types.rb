module Algorithms
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :regular
    # for algorithms with exists only in InterfaceGroups of SimpleClasses
    value :id => 2, :name => :class_level
  end
end