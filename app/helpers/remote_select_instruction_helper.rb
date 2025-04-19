module RemoteSelectInstructionHelper

  WRAPPER_STEP_ADDITION_FOR_REGULAR_CASE = "algorithm_form_wrapper_step_addition".freeze
  WRAPPER_STEP_ADDITION_FOR_CLASS_LEVEL_ALGORITHM = "algorithm_form_class_level_wrapper_step_addition".freeze
  WRAPPER_STEP_ADDITION_FOR_FRAMEWORK_LEVEL_ALGORITHM = "algorithm_form_framework_level_wrapper_step_addition".freeze
  SELECT_TYPE_ERROR = "Something went wrong with type".freeze

  REGULAR_FUNCTIONAL_TYPE = "regular".freeze
  CLASS_LEVEL_FUNCTIONAL_TYPE = "class_level".freeze
  FRAMEWORK_LEVEL_FUNCTIONAL_TYPE = "framework_level".freeze

  def remote_select_instruction_select_type(key)
    binding.pry
    if functional_type(key) == REGULAR_FUNCTIONAL_TYPE
      WRAPPER_STEP_ADDITION_FOR_REGULAR_CASE
    elsif functional_type(key) == CLASS_LEVEL_FUNCTIONAL_TYPE
      WRAPPER_STEP_ADDITION_FOR_CLASS_LEVEL_ALGORITHM
    elsif functional_type(key) == FRAMEWORK_LEVEL_FUNCTIONAL_TYPE
      WRAPPER_STEP_ADDITION_FOR_FRAMEWORK_LEVEL_ALGORITHM
    else
      SELECT_TYPE_ERROR
    end
  end

  def regular_functional_type?(key)
    Algorithms::FunctionalTypes[key] == REGULAR_FUNCTIONAL_TYPE || @functional_type == nil
  end

  def framework_level_functional_type?(key)
    Algorithms::FunctionalTypes[key] == FRAMEWORK_LEVEL_FUNCTIONAL_TYPE
  end

  def class_level_functional_type?(key)
    Algorithms::FunctionalTypes[key] == CLASS_LEVEL_FUNCTIONAL_TYPE
  end

  private

  def functional_type(key)
    Algorithms::FunctionalTypes[key]
  end

end
