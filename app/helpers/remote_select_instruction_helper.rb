module RemoteSelectInstructionHelper

  WRAPPER_STEP_ADDITION_FOR_REGULAR_CASE = "algorithm_form_wrapper_step_addition".freeze
  WRAPPER_STEP_ADDITION_FOR_CLASS_LEVEL_ALGORITHM = "algorithm_form_class_level_wrapper_step_addition".freeze
  SELECT_TYPE_ERROR = "Something went wrong with type".freeze

  REGULAR_FUNCT_TYPE = "regular".freeze
  CLASS_LEVEL_FUNCT_TYPE = "class_level".freeze

  def remote_select_instruction_select_type(key)
    binding.pry
    if functional_type(key) == REGULAR_FUNCT_TYPE
      WRAPPER_STEP_ADDITION_FOR_REGULAR_CASE
    elsif functional_type(key) == CLASS_LEVEL_FUNCT_TYPE
      WRAPPER_STEP_ADDITION_FOR_CLASS_LEVEL_ALGORITHM
    else
      SELECT_TYPE_ERROR
    end
  end

  def regular_functional_type?(key)
    Algorithms::FunctionalTypes[key] == REGULAR_FUNCT_TYPE || @functional_type == nil
  end

  private

  def functional_type(key)
    Algorithms::FunctionalTypes[key]
  end

end
