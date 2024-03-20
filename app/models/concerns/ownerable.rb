module Ownerable
  extend ActiveSupport::Concern

  included do
    has_many :repositories, :as => :ownerable, class_name: "Repository"

    has_many :articles, :as => :ownerable, class_name: "Articles::Article"
    has_many :units, :as => :ownerable, class_name: "Units::Unit"
    has_many :algorithms, :as => :ownerable, class_name: "Algorithms::Algorithm"
    has_many :cheat_sheets, :as => :ownerable, class_name: "CheatSheets::CheatSheet"
    has_many :cheat_sheet_groups, :as => :ownerable, class_name: "CheatSheetGroups::CheatSheetGroup"
    has_many :classes, :as => :ownerable, class_name: "SimpleClasses::SimpleClass"
    has_many :frameworks, :as => :ownerable, class_name: "Frameworks::Framework"
  end

  def ownername
    self.username
    # add organization here self.orgname
  end

end