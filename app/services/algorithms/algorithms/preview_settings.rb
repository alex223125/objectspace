module Services
  module Algorithms
    module Algorithms
      class PreviewSettings

        ALGORITHM_PREVIEW_CASES = ["dpo_instruction_select", "interface_member_addition",
                                   "algorithm_form_wrapper_step_addition",
                                   "interface_group_form_action_addition",
                                   "algorithm_form_class_level_wrapper_step_addition"].freeze
        ALGORITHM_PREVIEW_PATH = "algorithm/shared/partials/preview/algorithm/main_page".freeze

        attr_reader :path

        def initialize(preview_case)
          @preview_case = preview_case
        end

        def call
          if algorithm_preview?(@preview_case)
            @path = ALGORITHM_PREVIEW_PATH
          end
        end

        private

        def algorithm_preview?(preview_case)
          ALGORITHM_PREVIEW_CASES.include?(preview_case)
        end
      end
    end
  end
end