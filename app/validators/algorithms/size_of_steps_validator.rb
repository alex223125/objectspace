module Algorithms
  class SizeOfStepsValidator < ActiveModel::Validator

    MAX_ALLOWED_AMOUNT_OF_STEPS_PER_NEW_ALGORITHM_CREATION = 100.freeze

    def validate(record)
      binding.pry
      if total_amount(record) > MAX_ALLOWED_AMOUNT_OF_STEPS_PER_NEW_ALGORITHM_CREATION
        binding.pry
        record.errors.add(:steps, I18n.t('errors.messages.too_much_steps', amount: MAX_ALLOWED_AMOUNT_OF_STEPS_PER_NEW_ALGORITHM_CREATION))
      end
    end

    private

    def total_amount(record)
      @substeps_amount = 0
      calculate_amount_of_(record.algorithm_versions.first.control_structures.first.steps)
      @substeps_amount
    end

    def calculate_amount_of_(substeps)
      substeps.each do |step|
        @substeps_amount += 1
        calculate_amount_of_(step.substeps)
      end
    end



    # def total_amount(record)
    #   binding.pry
    #   first_layer_steps = record.algorithm_versions.first.control_structures.first.steps
    #   total_amount = 0
    #   total_amount += first_layer_steps.length
    #
    #   first_layer_steps.each do |step|
    #     total_amount += step.descendants.length
    #   end
    #   total_amount
    # end

    # binding.pry
    # if total_amount > MAX_ALLOWED_AMOUNT_OF_STEPS_PER_NEW_ALGORITHM_CREATION
    #   raise ::Algorithms::TooMuchStepsError
    #           .new("Too much steps, maximum allowed amount is #{MAX_ALLOWED_AMOUNT_OF_STEPS_PER_NEW_ALGORITHM_CREATION}.")
    # end


  end
end
