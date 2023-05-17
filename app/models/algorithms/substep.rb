class Algorithms::Substep < ApplicationRecord

  belongs_to :step
  acts_as_list scope: :step

  # belongs_to :unit, class_name: "Units::Unit", optional: true
  # belongs_to :algorithm, class_name: "Algorithms::Algorithm", optional: true

  belongs_to :substepable, polymorphic: true

  # добавить валидацию или юнит айди дожен быть
  # или алгоритм айди должен быть

  # переделать на полиморфную ассоциацию
  def readable_type
    if self.substepable_type == "Units::UnitVersion"
      "unit"
    elsif self.substepable_type == "Algorithms::AlgorithmVersion"
      "algorithm"
    end
  end

  # def entity
  #   if self.unit_id.present?
  #     self.unit
  #   else
  #     self.algorithm
  #   end
  # end

end
