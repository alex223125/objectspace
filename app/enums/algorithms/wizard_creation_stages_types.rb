module Algorithms
  class WizardCreationStagesTypes < ActiveEnum::Base
    value :id => 1, :name => :record_initiated
    value :id => 2, :name => :draft_created
    value :id => 3, :name => :complete_record_created
  end
end