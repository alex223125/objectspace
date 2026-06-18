# DOC: same as in ControlStructures::FunctionalTypes
module AlgorithmsNavigation
  module AlgorithmTrees
    class ReferencedControlStructureFunctionalType < ActiveEnum::Base
      value :id => 1, :name => :initial_template
      value :id => 2, :name => :sequential_flow
      # if_end
      value :id => 3, :name => :single_alternative
      # if_else_end
      value :id => 4, :name => :double_alternative
      # if_elsif_elsif_else_end
      value :id => 5, :name => :multiple_alternatives
    end
  end
end