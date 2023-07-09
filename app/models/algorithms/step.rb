class Algorithms::Step < ApplicationRecord

  # for creation logic
  attr_accessor :parent_id_dynamic_step,
                :current_step_frontend_id

  self.inheritance_column = nil

  belongs_to :control_structure, optional: true

  # cant use with clouser tree
  # acts_as_list scope: :control_structure

  # Units and Algorithms for wrapper type of steps 
  belongs_to :technologiable, polymorphic: true, optional: true

  # new approach:
  has_closure_tree order: 'position', numeric_order: true

  has_many :substeps,
           class_name: "Algorithms::Step",
           foreign_key: "parent_id"
  accepts_nested_attributes_for :substeps
  ####

  # OLD OPTION
  # has_many :substeps, class_name: "Algorithms::Substep"
  # accepts_nested_attributes_for :substeps

  # belongs_to :algorithm_version
  # acts_as_list scope: :algorithm_version

end
