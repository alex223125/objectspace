module AlgorithmReports
  module Nodes
    module LoggingSteps
      class LoggingStepIncludedContentTypes < ActiveEnum::Base
        value :id => 1, :name => :no_included_content
        value :id => 2, :name => :article
        value :id => 3, :name => :unit
        value :id => 4, :name => :algorithm
        value :id => 5, :name => :cheat_sheet
        value :id => 6, :name => :combo_cheat_sheet
      end
    end
  end
end