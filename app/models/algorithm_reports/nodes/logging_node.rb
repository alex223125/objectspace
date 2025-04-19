class AlgorithmReports::Nodes::LoggingNode < ApplicationRecord
  include Sequenciable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  has_closure_tree order: 'position', numeric_order: true

  belongs_to :duplicate_algorithm_version, class_name: "Algorithms::AlgorithmVersion", foreign_key: :algorithm_version_id,
             optional: true

  belongs_to :related_duplicate_algorithm_version, class_name: "Algorithms::AlgorithmVersion",
             foreign_key: :related_algorithm_version_id, optional: true
  has_one :algorithm, through: :duplicate_algorithm_version, class_name: "Algorithms::Algorithm"

  has_many :subnodes, -> { order 'logging_nodes.position ASC' },
           class_name: "AlgorithmReports::Nodes::LoggingNode",
           foreign_key: "parent_id",
           dependent: :destroy

  belongs_to :algorithm_report, class_name: "AlgorithmReports::AlgorithmReport", optional: true

  belongs_to :original_node, class_name: "Algorithms::Nodes::Node", foreign_key: :original_node_id

  def functional_type
    if self.step_functional_type.present?
      Steps::FunctionalTypes[self.step_functional_type]
    elsif self.control_structure_functional_type.present?
      ControlStructures::FunctionalTypes[self.control_structure_functional_type]
    end
  end

  def included_content_type_is_algorithm?
    self.logging_step_included_content_type == AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:algorithm]
  end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end