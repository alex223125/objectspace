class AlgorithmReports::Nodes::LoggingControlStructure < AlgorithmReports::Nodes::LoggingNode

  has_many :logging_steps, class_name: "AlgorithmReports::Nodes::LoggingStep"

  validates :algorithm_report, presence: true, if: :base_control_structure?

  def base_control_structure?
    self.control_structure_functional_type == LoggingControlStructures::FunctionalTypes[:initial_template]
  end
end