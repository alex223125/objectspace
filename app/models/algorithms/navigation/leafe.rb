class Algorithms::Navigation::Leafe < ApplicationRecord
  has_closure_tree order: 'position', numeric_order: true

  has_many :subleaves, -> { order 'leaves.position ASC' },
           class_name: "Algorithms::Navigation::Leafe",
           foreign_key: "parent_id",
           dependent: :destroy,
           :validate => true
  # accepts_nested_attributes_for :subleaves, allow_destroy: true

  # TODO: add validation this record shousd be present only for root leafe
  belongs_to :algorithm_tree, optional: true

  # TODO: add validation these 2 fields should be not optional only for all leaves whch ar not root leafe
  belongs_to :referencable, polymorphic: true, optional: true

  belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion", foreign_key: :algorithm_version_id, optional: true
  belongs_to :related_algorithm_version, class_name: "Algorithms::AlgorithmVersion",
             foreign_key: :related_algorithm_version_id, optional: true

  validates :algorithm_version, presence: true, if: :reference_from_base_control_structure?
  validates :related_algorithm_version, presence: true, if: :reference_from_not_base_control_strucutre?

  def reference_from_base_control_structure?
    self.referenced_control_structure_functional_type == ControlStructures::FunctionalTypes[:initial_template]
  end

  def reference_from_not_base_control_strucutre?
    !reference_from_base_control_structure?
  end


end