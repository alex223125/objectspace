module Services
  module Algorithms
    module Algorithms
      class PreviewSettings

        GENERAL_ALGORITHM_PREVIEW_CASES = ["dpo_instruction_select", "interface_member_addition",
                                           "algorithm_form_wrapper_step_addition",
                                           "interface_group_form_action_addition",
                                           "algorithm_form_class_level_wrapper_step_addition",
                                           "algorithm_form_class_level_wrapper_step_addition",
                                           "article_attachment_preview",
                                           "algorithm_form_framework_level_wrapper_step_addition"].freeze
        CHEAT_SHEET_FORM_NOTES_LINK_ATTACHMENT_PREVIEW = "cheat_sheet_from_notes_link_attachment_preview".freeze
        ALGORITHM_PREVIEW_PATH = "algorithm/shared/partials/preview/algorithm/main_page".freeze

        attr_reader :path, :scenario

        # TODO: preview_type not preview_case
        def initialize(preview_case)
          binding.pry
          @preview_case = preview_case
        end

        def call
          binding.pry
          if general_algorithm_preview_case?(@preview_case)

            binding.pry
            @path = ALGORITHM_PREVIEW_PATH
            @scenario = @preview_case
          elsif @preview_case == CHEAT_SHEET_FORM_NOTES_LINK_ATTACHMENT_PREVIEW

            binding.pry
            @path = "shared/tech_previews/basic_preview"
            @scenario = CHEAT_SHEET_FORM_NOTES_LINK_ATTACHMENT_PREVIEW
          end
        end


        def general_algorithm_preview_case?(preview_case)
          binding.pry
          GENERAL_ALGORITHM_PREVIEW_CASES.include?(preview_case)
        end
      end
    end
  end
end