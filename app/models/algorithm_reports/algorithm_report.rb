class AlgorithmReports::AlgorithmReport < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  # extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_start: [:title, :description],
             text_middle: [:title, :description],
             text_end: [:title, :description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags


  belongs_to :ownerable, polymorphic: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  # TODO: add validation that one of these 3 should definitely exists
  # for record to be saved
  belongs_to :reports_repository, class_name: "ReportsRepository", optional: true
  belongs_to :folder, class_name: "Folder", optional: true
  # DOC: only to logging steps with "wrapper" functional type
  belongs_to :logging_step, class_name: "AlgorithmReports::Nodes::LoggingStep", optional: true, foreign_key: :logging_step_id

  belongs_to :duplicate_algorithm_version, class_name: "Algorithms::AlgorithmVersion", foreign_key: :algorithm_version_id
  has_one :algorithm_version, through: :duplicate_algorithm_version,
          class_name: "Algorithms::AlgorithmVersion"

  has_one :logging_introduction_step, class_name: "AlgorithmReports::LoggingIntroductionStep"

  has_many :logging_nodes, class_name: "AlgorithmReports::Nodes::LoggingNode"
  has_many :related_logging_nodes, class_name: "AlgorithmReports::Nodes::LoggingNode", foreign_key: :algorithm_report_id
  has_many :logging_control_structures, class_name: "AlgorithmReports::Nodes::LoggingControlStructure"

  # # used
  # has_many :control_structures, class_name: "Algorithms::Nodes::ControlStructure"
  # accepts_nested_attributes_for :control_structures, allow_destroy: true

  has_closure_tree_root :root_logging_node,
                        class_name: "AlgorithmReports::Nodes::LoggingNode",
                        foreign_key: "algorithm_report_id"

  def base_control_structure
    self.logging_control_structures
        .where(control_structure_functional_type: LoggingControlStructures::FunctionalTypes[:initial_template]).first
  end

  def first_step
    base_control_structure.children.where(position: 0).first
  end

  def completed?
    self.completion_state == AlgorithmReports::CompletionStateTypes[:completed]
  end

  def in_progress?
    self.completion_state == AlgorithmReports::CompletionStateTypes[:in_progress]
  end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end