class Algorithms::Nodes::Node < ApplicationRecord
  include Sequenciable

  # for creation logic
  attr_accessor :parent_id_dynamic_node,
                :current_node_frontend_id

  STEP_TYPE = "Algorithms::Nodes::Step".freeze
  CONTROL_STRUCTURE_INITIAL_TEMPLATE_FUNCTIONAL_TYPE = "initial_template".freeze

  STEP_REGULAR_FUNCTIONAL_TYPE = "regular"
  STEP_WRAPPER_FUNCTIONAL_TYPE = "wrapper"
  STEP_CONTAINER_FUNCTIONAL_TYPE = "container"

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  has_closure_tree order: 'position', numeric_order: true

  #DOC: related_algorithm_version - for nodes which are down in tree structure
  # but not the first one which linked via belongs_to :algorithm_version
  # belongs_to :related_algorithm_version, class_name: "Algorithms::AlgorithmVersion",
  #            foreign_key: :related_algorithm_version_id
  #
  # belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion"

  belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion", optional: true

  belongs_to :related_algorithm_version, class_name: "Algorithms::AlgorithmVersion",
             foreign_key: :related_algorithm_version_id, optional: true

  has_one :algorithm, through: :algorithm_version, class_name: "Algorithms::Algorithm"

  has_one :leafe, as: :referencable, class_name: "Algorithms::Navigation::Leafe"

  # TODO add validation, it step type container, then we should have at least 1 method inside of it
  has_many :subnodes, -> { order 'nodes.position ASC' },
           class_name: "Algorithms::Nodes::Node",
           foreign_key: "parent_id",
           dependent: :destroy
  accepts_nested_attributes_for :subnodes, allow_destroy: true

  has_many :attachments, class_name: "Attachment"
  accepts_nested_attributes_for :attachments, allow_destroy: true

  # DOC: Warning! It will take logging nodes which are from different AlgorithmReports
  has_many :logging_nodes, class_name: "AlgorithmReports::Nodes::LoggingNode", foreign_key: :original_node_id

  belongs_to :original_node, class_name: "Algorithms::Nodes::Node", foreign_key: :original_node_id, optional: true
  validates :original_node, presence: true, if: :backend_storage_type_duplicate?

  def backend_storage_type_original?
    self.backend_storage_type_id == Nodes::BackendStorageTypes[:original]
  end

  def backend_storage_type_duplicate?
    self.backend_storage_type_id == Nodes::BackendStorageTypes[:original]
  end

  # module Nodes
  #   class BackendStorageTypes < ActiveEnum::Base
  #     value :id => 1, :name => :original
  #     # duplicate - the one which is used in algorithmReports
  #     value :id => 2, :name => :duplicate
  #   end
  # end

  def closest_algorithm_version
    self.algorithm_version || self.related_algorithm_version
  end

  def functional_type_id
    if self.type == "Algorithms::Nodes::Step"
      self.step_functional_type
    elsif self.type == "Algorithms::Nodes::ControlStructure"
      self.control_structure_functional_type
    end
  end

  def step_type?
    self.type == STEP_TYPE
  end

  def functional_type
    if self.step_functional_type.present?
      Steps::FunctionalTypes[self.step_functional_type]
    elsif self.control_structure_functional_type.present?
      ControlStructures::FunctionalTypes[self.control_structure_functional_type]
    end
  end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end
