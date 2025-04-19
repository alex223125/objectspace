class SimpleClasses::SimpleClassInterface < ApplicationRecord

  belongs_to :simple_class, class_name: "SimpleClasses::SimpleClass"
  has_many :algorithms, class_name: "Algorithms::Algorithm"

end
