### Algorthm version have different stages of creation
# stage_of_creation
# draft_created
# main_created
# introduction_created
# performing_content_created
# finishing_content_created

module AlgorithmVersions
  class WizardCreationStagesTypes < ActiveEnum::Base
    value :id => 1, :name => :record_initiated
    value :id => 2, :name => :draft_created
    value :id => 3, :name => :main_created
    value :id => 4, :name => :introduction_created
    value :id => 5, :name => :performing_content_created
    value :id => 6, :name => :finishing_content_created
    value :id => 7, :name => :complete_record_created
  end
end