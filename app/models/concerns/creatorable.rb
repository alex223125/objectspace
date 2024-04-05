# DOC: Creator - someone who created entity. We setting this one once and not changing after it
module Creatorable
  extend ActiveSupport::Concern

  included do
    has_many :units, :foreign_key => "creator_id", :class_name => "Units::Unit"
    has_many :cheat_sheet_groups, :foreign_key => "creator_id", :class_name => "CheatSheetGroups::CheatSheetGroup"
    has_many :simple_classes, :foreign_key => "creator_id", :class_name => "SimpleClasses::SimpleClasses"
    has_many :class_containers, :foreign_key => "creator_id", :class_name => "SimpleClasses::ClassContainer"
    has_many :interface_groups, :foreign_key => "creator_id", :class_name => "SimpleClasses::InterfaceGroup"
  end
end