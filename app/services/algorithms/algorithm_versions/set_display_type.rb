module Services
  module Algorithms
    module AlgorithmVersions
      class SetDisplayType

        AMOUNT_OF_WORDS_FOR_DYNAMIC_STEP_BY_STEP_WINDOW_DISPLAY_STYLE = 10000.freeze
        TOP_LEVEL_STEPS_FOR_DYNAMIC_STEP_BY_STEP_WINDOW_DISPLAY_STYLE = 5.freeze

        def initialize(algorithm_version)
          @algorithm_version = algorithm_version
          @total_words = 0
        end

        def call
          binding.pry
          calculate_total_amount(@algorithm_version)
          set_type
          set_words_amount
          @algorithm_version.save!
        end

        private

        def calculate_total_amount(root_structure)
          children = structure_children(root_structure)
          children.each do |node|
            binding.pry
            if node.functional_type_id == ::Steps::FunctionalTypes[:regular]
              content = node.instruction
              amount = WordsCounted.count(content).token_count
              increase_on_(amount)
              # return if conditions_satisfied?
            elsif node.functional_type_id == ::Steps::FunctionalTypes[:wrapper]
              if node.technologiable.class == ::Units::Unit
                content = node.technologiable.default_version.instruction
                amount = WordsCounted.count(content).token_count
                increase_on_(amount)
                # return if conditions_satisfied?
              elsif node.technologiable.class == ::Algorithms::Algorithm
                algorithm_version = node.technologiable.default_version
                # DOC: warning! recursion
                calculate_total_amount(algorithm_version)
                # return if conditions_satisfied?
              elsif node.technologiable.class == ::CheatSheets::CheatSheet
                cheat_sheet_version = node.technologiable.default_version
                notes = cheat_sheet_version.notes
                notes.each do |note|
                  content = note.content
                  amount = WordsCounted.count(content).token_count
                  increase_on_(amount)
                  # return if conditions_satisfied?
                end
              elsif node.technologiable.class == ::CheatSheetGroups::CheatSheetGroup
                calculate_total_amount_for_cheat_sheet_group(node.technologiable)
              end
            elsif node.functional_type_id == ::Steps::FunctionalTypes[:container]
              # DOC: warning! recursion
              calculate_total_amount(node)
            end
          end
        end

        def calculate_total_amount_for_cheat_sheet_group(cheat_sheet_group)
          cheat_sheet_group_version = cheat_sheet_group.default_version
          sections = cheat_sheet_group_version.sections
          sections.each do |section|
            if section.sectionable.class == ::Articles::Article
              article_version = section.sectionable.default_version
              content = article_version.content
              amount = WordsCounted.count(content).token_count
              increase_on_(amount)
              # return if conditions_satisfied?
            elsif section.sectionable.class == ::Units::Unit
              unit_version = section.sectionable.default_version
              content = unit_version.instruction
              amount = WordsCounted.count(content).token_count
              increase_on_(amount)
              # return if conditions_satisfied?
            elsif section.sectionable.class == ::CheatSheets::CheatSheet
              cheat_sheet_version = section.sectionable.default_version
              notes = cheat_sheet_version.notes
              notes.each do |note|
                content = note.content
                amount = WordsCounted.count(content).token_count
                increase_on_(amount)
                # return if conditions_satisfied?
              end
            elsif section.sectionable.class == ::CheatSheetGroups::CheatSheetGroup
              # DOC: Warning! Recursion
              calculate_total_amount_for_cheat_sheet_group(section.sectionable)
            end
          end
        end

        def structure_children(structure)
          if structure.class == ::Algorithms::AlgorithmVersion
            children = structure.base_control_structure.children
          elsif structure.class == ::Algorithms::Nodes::Step && structure.functional_type_id == ::Steps::FunctionalTypes[:container]
            children = structure.children
          end
          children
        end

        def increase_on_(amount)
          @total_words = @total_words + amount
        end

        def set_type
          if condition_for_dynamic_display_satisfied?
            @algorithm_version.display_type = ::AlgorithmVersions::DisplayTypes[:dynamic_step_by_step_window]
          else
            @algorithm_version.display_type = ::AlgorithmVersions::DisplayTypes[:everything_on_one_page]
          end
        end

        def set_words_amount
          @algorithm_version.whole_tree_content_words_amount = @total_words.to_s
        end

        def condition_for_dynamic_display_satisfied?
          binding.pry
          if @total_words >= AMOUNT_OF_WORDS_FOR_DYNAMIC_STEP_BY_STEP_WINDOW_DISPLAY_STYLE
            true
          # DOC: if we have more than 5 top-tier steps in algorithm
          elsif @algorithm_version.base_control_structure.children.count > TOP_LEVEL_STEPS_FOR_DYNAMIC_STEP_BY_STEP_WINDOW_DISPLAY_STYLE
            binding.pry
            true
          else
            false
          end
        end
      end
    end
  end
end
