module StepsHelper

  def path_to_next_step(current_step)
    next_step = current_step.next_node

    if next_step.present?
      algorithm_version = next_step.closest_algorithm_version
      algorithm_version_step_path(ownername: algorithm_version.algorithm.ownerable.ownername,
                                  algorithm_version_id: algorithm_version.slug,
                                  id: next_step.slug)
    else
      nil
    end
  end

  def path_to_previous_step(current_step)
    previous_step = current_step.previous_node

    if previous_step.present?
      algorithm_version = previous_step.closest_algorithm_version
      algorithm_version_step_path(ownername: algorithm_version.algorithm.ownerable.ownername,
                                  algorithm_version_id: algorithm_version.slug,
                                  id: previous_step.slug)
    else
      nil
    end
  end

end