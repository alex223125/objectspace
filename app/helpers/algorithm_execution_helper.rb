module AlgorithmExecutionHelper

  LOGGING_NODES_CLASSES = [AlgorithmReports::Nodes::LoggingNode, AlgorithmReports::Nodes::LoggingStep, AlgorithmReports::Nodes::LoggingControlStructure].freeze

  def path_to_first_execution_step(current_step)
    step = current_step.algorithm_report.first_step
    algorithm_reports_algorithm_execution_path(logging_step_id: step.uuid)
  end


  def path_to_next_execution_step(current_step)
    if current_step.class == AlgorithmReports::LoggingIntroductionStep
      path_to_first_execution_step(current_step)
    else
      # next_step = current_step.next_node
      #
      # if next_step.present?
      #   algorithm_version = next_step.closest_algorithm_version
      #   algorithm_version_step_path(ownername: algorithm_version.algorithm.ownerable.ownername,
      #                               algorithm_version_id: algorithm_version.slug,
      #                               id: next_step.slug)
      # else
      #   nil
      # end
    end
  end

  def path_to_previous_execution_step(current_step)
    binding.pry
    if current_step.class == AlgorithmReports::LoggingIntroductionStep
      edit_algorithm_reports_algorithm_report_path(id: current_step.algorithm_report.uuid)
    elsif one_of_logging_nodes?(current_step.class)
      previous_step = current_step.previous_node

      if previous_step.present?
        algorithm_reports_algorithm_execution_path(previous_step.uuid)
      elsif first_step_after_introduction?(current_step)
        algorithm_reports_algorithm_execution_initial_place_path(uuid: current_step.algorithm_report.uuid)
      else
        nil
      end
    end
  end

  def one_of_logging_nodes?(current_step_class)
    LOGGING_NODES_CLASSES.include?(current_step_class)
  end

  def first_step_after_introduction?(current_step)
    current_step.previous_node.blank? && current_step.parent.control_structure_functional_type == ControlStructures::FunctionalTypes[:initial_template]
  end

  def last_algorithm_execution_step?(current_step)
    current_step.next_node.blank? && current_step.parent.control_structure_functional_type == ControlStructures::FunctionalTypes[:initial_template]
  end

  def next_step_present?(current_step)
    current_step.next_node.present?
  end


  # def path_to_next_step(current_step)
  #   next_step = current_step.next_node
  #
  #   if next_step.present?
  #     algorithm_version = next_step.closest_algorithm_version
  #     algorithm_version_step_path(ownername: algorithm_version.algorithm.ownerable.ownername,
  #                                 algorithm_version_id: algorithm_version.slug,
  #                                 id: next_step.slug)
  #   else
  #     nil
  #   end
  # end
  #
  # def path_to_previous_step(current_step)
  #   previous_step = current_step.previous_node
  #
  #   if previous_step.present?
  #     algorithm_version = previous_step.closest_algorithm_version
  #     algorithm_version_step_path(ownername: algorithm_version.algorithm.ownerable.ownername,
  #                                 algorithm_version_id: algorithm_version.slug,
  #                                 id: previous_step.slug)
  #   else
  #     nil
  #   end
  # end

end