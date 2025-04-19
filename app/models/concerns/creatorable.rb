# DOC: Creator - someone who created entity. We setting this one once and not changing after it
module Creatorable
  extend ActiveSupport::Concern

  included do
    has_many :articles, :foreign_key => "creator_id", :class_name => "Articles::Article"
    has_many :units, :foreign_key => "creator_id", :class_name => "Units::Unit"
    has_many :algorithms, :foreign_key => "creator_id", :class_name => "Algorithms::Algorithm"
    has_many :cheat_sheets, :foreign_key => "creator_id", :class_name => "CheatSheets::CheatSheet"
    has_many :cheat_sheet_groups, :foreign_key => "creator_id", :class_name => "CheatSheetGroups::CheatSheetGroup"
    has_many :simple_classes, :foreign_key => "creator_id", :class_name => "SimpleClasses::SimpleClasses"
    has_many :simple_class_attributes, :foreign_key => "creator_id", :class_name => "SimpleClasses::SimpleClassAttribute"
    has_many :class_containers, :foreign_key => "creator_id", :class_name => "SimpleClasses::ClassContainer"
    has_many :interface_groups, :foreign_key => "creator_id", :class_name => "SimpleClasses::InterfaceGroup"

    has_many :framework_folders, :foreign_key => "creator_id", :class_name => "Frameworks::FrameworkFolder"

    has_many :improvements, :foreign_key => "creator_id", :class_name => "Improvements::Improvement"

    has_many :algorithm_reports, :foreign_key => "creator_id", :class_name => "AlgorithmReports::AlgorithmReport"
  end
end