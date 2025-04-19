module Ownerable
  extend ActiveSupport::Concern

  included do
    has_many :articles, :as => :ownerable, class_name: "Articles::Article"
    has_many :units, :as => :ownerable, class_name: "Units::Unit"
    has_many :algorithms, :as => :ownerable, class_name: "Algorithms::Algorithm"
    has_many :cheat_sheets, :as => :ownerable, class_name: "CheatSheets::CheatSheet"
    has_many :cheat_sheet_groups, :as => :ownerable, class_name: "CheatSheetGroups::CheatSheetGroup"
    has_many :classes, :as => :ownerable, class_name: "SimpleClasses::SimpleClass"
    has_many :simple_class_attributes, :as => :ownerable, class_name: "SimpleClasses::SimpleClassAttribute"
    has_many :frameworks, :as => :ownerable, class_name: "Frameworks::Framework"

    has_many :improvements, :as => :ownerable, class_name: "Improvements::Improvement"


    has_many :algorithm_reports, :as => :ownerable, class_name: "AlgorithmReports::AlgorithmReport"


    has_many :repositories, :as => :ownerable, class_name: "Repository"
    has_many :repository_folders, through: :repositories, class_name: "Folder"

    has_many :reports_repositories, :as => :ownerable, class_name: "ReportsRepository"
    has_many :reports_repository_folders, through: :reports_repositories, class_name: "Folder"

    def default_reports_repository
      reports_repositories.where(functional_type: ReportsRepositories::FunctionalTypes[:default_user_reports_repository]).first
    end
  end

  def ownername
    self.username
    # add organization here self.orgname
  end

end