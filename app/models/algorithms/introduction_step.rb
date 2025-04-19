class Algorithms::IntroductionStep < ApplicationRecord

  belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion"
  has_one :logging_introduction_step, class_name: "AlgorithmReports::LoggingIntroductionStep",
          foreign_key: :introduction_step_id
end
