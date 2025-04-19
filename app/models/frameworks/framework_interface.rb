class Frameworks::FrameworkInterface < ApplicationRecord

  belongs_to :framework, class_name: "Frameworks::Framework"
  has_many :algorithms, class_name: "Algorithms::Algorithm"

end

