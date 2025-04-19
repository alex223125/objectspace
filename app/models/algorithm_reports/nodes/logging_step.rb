class AlgorithmReports::Nodes::LoggingStep < AlgorithmReports::Nodes::LoggingNode


  has_many :algorithm_reports_based_on_included_algorithms, class_name: "AlgorithmReports::AlgorithmReport"

end