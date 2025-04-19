module AlgorithmReports
  class CompletionStateTypes < ActiveEnum::Base
    value :id => 1, :name => :in_progress
    value :id => 2, :name => :completed
  end
end