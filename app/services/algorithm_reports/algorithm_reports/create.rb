module Services
  module AlgorithmReports
    module AlgorithmReports
      class Create

        attr_reader :errors, :algorithm_report

        def initialize(params, algorithm_version, current_user)
          @params = params
          @algorithm_version = algorithm_version
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            set_duplicate_algorithm_version

            binding.pry
            create_algorithm_report
            set_creator
            set_default_reports_repository
            set_duplicate_algorithm_version_for_algorithm_report
            set_ownerable
            set_tags
            set_completion_state

            # @algorithm_report.logging_nodes << @logging_nodes

            binding.pry
            create_introduction_logging_step
            create_logging_nodes

            binding.pry
            create_algorithm_reports_for_logging_steps_with_included_algorithms
            binding.pry
            set_default_reports_repository

            binding.pry
            @algorithm_report.logging_nodes << @logging_nodes
            binding.pry
            @algorithm_report.save!
            # rebuild_positions_of_nodes
            # binding.pry
            # create_logging_nodes
            # sequently_save_nodes!

            # DOC: uuid is nil if we not reload
            @algorithm_report.reload
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        # def set_position_for_root_control_structure
        #
        # end

        # def rebuild_positions_of_nodes
        #   @algorithm_report.logging_nodes.each do |logging_node|
        #     logging_node.position = logging_node.original_node.position
        #     logging_node.save!
        #   end
        # end

        # in case if parameters not provided to which folder put this report
        # def set_default_reports_repository
        #   default_reports_repository = @algorithm_report.creator.reports_repository
        #   @algorithm_report.reports_repository = default_reports_repository
        # end

        def set_creator
          @algorithm_report.creator = @current_user
        end

        def create_algorithm_report
          @algorithm_report = ::AlgorithmReports::AlgorithmReport.new(@params)
          @algorithm_report.save(validate: false)
        end

        def set_duplicate_algorithm_version_for_algorithm_report
          @algorithm_report.duplicate_algorithm_version = @algorithm_version.latest_duplicate_algorithm_version
        end

        def set_duplicate_algorithm_version
          binding.pry
          @duplicate_algorithm_version = @algorithm_version.latest_duplicate_algorithm_version
          # if @algorithm_version.duplicate_algorithm_versions.present?
          #   if current_version_of_duplicate_algorithm_version_is_the_latest?
          #     binding.pry
          #     @duplicate_algorithm_version = @algorithm_version.latest_duplicate_algorithm_version
          #   else
          #     binding.pry
          #     create_newest_duplicate_of_algorithm_version
          #   end
          # else
          #   binding.pry
          #   create_newest_duplicate_of_algorithm_version
          # end
        end

        def current_version_of_duplicate_algorithm_version_is_the_latest?
          version_number = @algorithm_version.original_algorithm_version_version_number
          latest_duplicate_algorithm_version = @algorithm_version.latest_duplicate_algorithm_version
          duplicate_algorithm_version_version_number = latest_duplicate_algorithm_version.duplicate_algorithm_verion_version_number
          version_number == duplicate_algorithm_version_version_number
        end


        # def create_newest_duplicate_of_algorithm_version
        #   binding.pry
        #   service = Services::Algorithms::AlgorithmVersions::CreateNewestDuplicateOfAlgorithmVersion.new(@algorithm_version)
        #   service.call
        #   @duplicate_algorithm_version = service.duplicate_algorithm_version
        # end

        def create_logging_nodes
          binding.pry
          # DOC: We iterate from bottom of the tree up to root node
          # nodes = @duplicate_algorithm_version.root_node.self_and_descendants.reverse
          nodes = @duplicate_algorithm_version.root_node.self_and_descendants
          @logging_nodes = []

          binding.pry
          nodes.each do |original_node|

            binding.pry
            create_logging_node(original_node)
          end
        end

        # TODO move this logic into different service objects for testability
        def create_logging_node(original_node)
          binding.pry
          return if present_in_logging_nodes?(original_node)

          if original_node.type == "Algorithms::Nodes::Node"
            logging_node = ::AlgorithmReports::Nodes::LoggingNode.new
          elsif original_node.type == "Algorithms::Nodes::Step"
            logging_node = ::AlgorithmReports::Nodes::LoggingStep.new
          elsif original_node.type == "Algorithms::Nodes::ControlStructure"
            logging_node = ::AlgorithmReports::Nodes::LoggingControlStructure.new
          end


          logging_node.position = original_node.position
          logging_node.step_functional_type = original_node.step_functional_type
          logging_node.control_structure_id = original_node.control_structure_id
          logging_node.control_structure_functional_type = original_node.control_structure_functional_type
          # linking with duplicate algorithm version
          logging_node.duplicate_algorithm_version = @duplicate_algorithm_version
          logging_node.algorithm_report = @algorithm_report

          # DOC: Warning! Recursion!
          # set parent
          binding.pry
          if original_node.parent.present?
            binding.pry
            if present_in_logging_nodes?(original_node.parent)
              binding.pry
              logging_node.parent = select_logging_node(original_node.parent)
            else
              binding.pry
              parent = create_logging_node(original_node.parent)
              logging_node.parent = parent
            end
          end

          logging_node.related_algorithm_version_id = @duplicate_algorithm_version.id
          logging_node.original_node_id = original_node.id
          logging_node.title = original_node.title


          # set included content type
          if logging_node.class == ::AlgorithmReports::Nodes::LoggingStep
            if logging_node.step_functional_type == Steps::FunctionalTypes[:wrapper]
              if logging_node.original_node.technologiable_type == "Articles::Article"
                logging_node.logging_step_included_content_type = ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:article]
              elsif logging_node.original_node.technologiable_type == "Units::Unit"
                logging_node.logging_step_included_content_type = ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:unit]
              elsif logging_node.original_node.technologiable_type == "Algorithms::Algorithm"
                logging_node.logging_step_included_content_type = ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:algorithm]
              elsif logging_node.original_node.technologiable_type == "CheatSheets::CheatSheet"
                logging_node.logging_step_included_content_type = ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:cheat_sheet]
              elsif logging_node.original_node.technologiable_type == "CheatSheetGroups::CheatSheetGroup"
                logging_node.logging_step_included_content_type = ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:combo_cheat_sheet]
              end
            else
              logging_node.logging_step_included_content_type = ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:no_included_content]
            end
          end

          @logging_nodes << logging_node
          logging_node
        end


        def present_in_logging_nodes?(original_node)
          select_logging_node(original_node).present?
        end

        def select_logging_node(original_node)
          @logging_nodes.select{|logging_node| logging_node.original_node_id == original_node.id }.first
        end

        def create_introduction_logging_step
          binding.pry
          introduction_logging_step = @algorithm_report.build_logging_introduction_step
          introduction_logging_step.original_introduction_step = @duplicate_algorithm_version.introduction_step
        end

        def create_algorithm_reports_for_logging_steps_with_included_algorithms
          binding.pry
          logging_steps_with_included_algorithm.each do |logging_step|

            binding.pry
            algorithm = logging_step.original_node.technologiable
            # title = algorithm.title
            algorithm_versions = algorithm.algorithm_versions
            # DOC: we creating AlgorithmReport for each version of attached algorithm
            # so user during execution of AlgorithmReport will be able to choose
            # which one he uses during going though steps
            algorithm_versions.each do |algorithm_version|

              binding.pry
              algorithm_report_params = { title: algorithm_version.title, description: algorithm_version.description }
              service = Services::AlgorithmReports::AlgorithmReports::Create.new(algorithm_report_params,
                                                                                 algorithm_version, @current_user)
              service.call
              algorithm_report = service.algorithm_report

              binding.pry
              logging_step.algorithm_reports_based_on_included_algorithms << algorithm_report
              # TODO: add error handler
            end
          end
        end

        def logging_steps_with_included_algorithm
          binding.pry
          @logging_nodes.select{|logging_node| logging_node.logging_step_included_content_type == ::AlgorithmReports::Nodes::LoggingSteps::LoggingStepIncludedContentTypes[:algorithm] }
        end


        # # DOC: closure tree has "behinde scenes" behavior and changes "position" alias_attribure
        # # as it thinks it should be instead of using value which we assining when we creating
        # # duplicate nodes. So we should use positon to go one by one though tree and save records
        # # using value of position attribute instead of saving them all tougether chaotically
        # def sequently_save_nodes!
        #   save_initial_template!
        #   save_children_nodes!
        # end
        #
        # def save_children_nodes!
        #   root_control_structure.children.sort_by(&:position).each do |logging_node|
        #     logging_node.save!
        #   end
        # end
        #
        # def save_initial_template!
        #   root_control_structure.save!
        # end
        #
        # def root_control_structure
        #   @root_control_structure ||= begin
        #     initial_template_id = LoggingControlStructures::FunctionalTypes[:initial_template]
        #     root_control_structure = @logging_nodes.select{|logging_node| logging_node.control_structure_functional_type == initial_template_id }.first
        #     root_control_structure
        #   end
        # end

        # in case if parameters not provided to which folder put this report
        def set_default_reports_repository
          @algorithm_report.reports_repository = @current_user.default_reports_repository
        end

        def set_ownerable
          @algorithm_report.ownerable = @current_user
        end

        def set_completion_state
          @algorithm_report.completion_state = ::AlgorithmReports::CompletionStateTypes[:in_progress]
        end

        # TODO - move into concern for all service objects
        def set_tags
          binding.pry
          @algorithm_report.tag_list = parse_tags
        end

        def parse_tags
          if @params[:tag_list].present?
            JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
          end
        end

      end
    end
  end
end