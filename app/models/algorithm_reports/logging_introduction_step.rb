class AlgorithmReports::LoggingIntroductionStep < ApplicationRecord

  belongs_to :algorithm_report, class_name: "AlgorithmReports::AlgorithmReport"
  belongs_to :original_introduction_step, class_name: "Algorithms::IntroductionStep", foreign_key: :introduction_step_id

end
