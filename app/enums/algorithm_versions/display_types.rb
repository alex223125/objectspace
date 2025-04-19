module AlgorithmVersions
  class DisplayTypes < ActiveEnum::Base
    value :id => 1, :name => :not_defined
    value :id => 2, :name => :everything_on_one_page
    value :id => 3, :name => :dynamic_step_by_step_window
  end
end