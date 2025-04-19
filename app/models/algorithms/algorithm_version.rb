class Algorithms::AlgorithmVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :algorithm

  # has_many :control_structures, class_name: "Algorithms::ControlStructure"
  # accepts_nested_attributes_for :control_structures

  belongs_to :algorithm_tree, class_name: "Algorithms::Navigation::AlgorithmTree",
          foreign_key: :algorithm_tree_id

  has_many :nodes, class_name: "Algorithms::Nodes::Node"
  accepts_nested_attributes_for :nodes, allow_destroy: true

  # we need it to create initial control structure "following"
  has_many :control_structures, class_name: "Algorithms::Nodes::ControlStructure"
  accepts_nested_attributes_for :control_structures, allow_destroy: true

  has_many :included_nodes, class_name: "Algorithms::Nodes::Node", foreign_key: :related_algorithm_version_id

  # has_many :attachments, as: :attachable, class_name: "Attachment"
  # accepts_nested_attributes_for :control_structures, allow_destroy: true

  # has_many :steps, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  # has_many :substeps, as: :substepable

  belongs_to :original_algorithm_version,
             class_name: 'Algorithms::AlgorithmVersion',
             inverse_of: :duplicate_algorithm_versions, optional: true
  has_many :duplicate_algorithm_versions,
           class_name: 'Algorithms::AlgorithmVersion',
           foreign_key: 'original_algorithm_version_id',
           inverse_of: :original_algorithm_version

  has_closure_tree_root :root_node,
                        class_name: "Algorithms::Nodes::Node",
                        foreign_key: "algorithm_version_id"

  has_many :algorithm_reports, class_name: "AlgorithmReports::AlgorithmReport"

  has_one :introduction_step, class_name: "Algorithms::IntroductionStep"
  accepts_nested_attributes_for :introduction_step, allow_destroy: true

  scope :original_algorithm_verions, ->{ where(original_algorithm_verion_id: nil) }

  #As duplicate algorithm version
  has_many :logging_nodes, class_name: "AlgorithmReports::Nodes::LoggingNode"

  validates :control_structures, presence: { message: "Algorithm should have at least 1 step" }
  # validates :nodes, presence: { message: "Algorithm should have at least 1 step" }

  validates :title, presence: true
  validates :backend_storage_type_id, presence: true
  validates :original_algorithm_version_version_number, presence: true, if: :backend_storage_type_original?
  validates :duplicate_algorithm_verion_version_number, presence: true, if: :backend_storage_type_duplicate?
  validates :original_algorithm_version_id, presence: true, if: :backend_storage_type_duplicate?

  scope :ordered_by_created_at, -> { order(created_at: :desc) }

  def backend_storage_type_original?
    self.backend_storage_type_id == AlgorithmVersions::BackendStorageTypes[:original]
  end

  def backend_storage_type_duplicate?
    self.backend_storage_type_id == AlgorithmVersions::BackendStorageTypes[:duplicate]
  end

  alias_method :whole_unit, :algorithm

  def latest_duplicate_algorithm_version
    self.duplicate_algorithm_versions.last
  end

  def class_key
    "algorithm_version"
  end

  def uniq_key
    class_key + self.uuid
  end

  def base_control_structure
    self.control_structures.where(control_structure_functional_type: ControlStructures::FunctionalTypes[:initial_template]).first
  end

  def first_step
    base_control_structure.children.where(position: 0).first
  end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end