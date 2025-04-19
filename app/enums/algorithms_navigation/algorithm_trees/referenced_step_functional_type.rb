# DOC: Same types as in Steps::FunctionalTypes
module AlgorithmsNavigation
  module AlgorithmTrees
    class ReferencedStepFunctionalTypes < ActiveEnum::Base
      value :id => 1, :name => :regular
      value :id => 2, :name => :wrapper
      value :id => 3, :name => :container
    end
  end
end
