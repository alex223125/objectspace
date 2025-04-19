module Services
  module Algorithms
    module AlgorithmVersions
      class CreateNewestDuplicateOfAlgorithmVersion

        attr_reader :duplicate_algorithm_version

        def initialize(original_algorithm_version)
          @original_algorithm_version = original_algorithm_version
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_duplicate_algorithm_version
            create_introduction_step

            # @duplicate_algorithm_version.nodes << @duplicate_nodes
            binding.pry
            create_duplicate_nodes
            binding.pry
            @duplicate_algorithm_version.nodes << @duplicate_nodes
            # @duplicate_algorithm_version.save(validate: false)
            binding.pry
            @duplicate_algorithm_version.save!
            # rebuild_positions_of_nodes
            # binding.pry
            # create_duplicate_nodes
            # binding.pry
            # sequently_save_nodes!

            # binding.pry
            # rebuild_positions_of_nodes

            # binding.pry
            # @duplicate_algorithm_version.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        # def rebuild_positions_of_nodes
        #   @duplicate_algorithm_version.nodes.each do |node|
        #     node.position = node.original_node.position
        #     node.save!
        #   end
        # end

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
        #   root_control_structure.children.sort_by(&:position).each do |duplicate_node|
        #     duplicate_node.save!
        #   end
        # end
        #
        # def save_initial_template!
        #   root_control_structure.save!
        # end

        def root_control_structure
          @root_control_structure ||= begin
            initial_template_id = ControlStructures::FunctionalTypes[:initial_template]
            root_control_structure = @duplicate_nodes.select{|duplicate_node| duplicate_node.control_structure_functional_type == initial_template_id }.first
            root_control_structure
          end
        end

        def create_duplicate_algorithm_version
          binding.pry
          @duplicate_algorithm_version = ::Algorithms::AlgorithmVersion.new
          @duplicate_algorithm_version.title = @original_algorithm_version.title
          @duplicate_algorithm_version.solves_the_problem = @original_algorithm_version.solves_the_problem
          @duplicate_algorithm_version.sources = @original_algorithm_version.sources
          @duplicate_algorithm_version.additional_information = @original_algorithm_version.additional_information
          @duplicate_algorithm_version.algorithm_id = @original_algorithm_version.algorithm_id
          @duplicate_algorithm_version.target_audience = @original_algorithm_version.target_audience
          @duplicate_algorithm_version.description = @original_algorithm_version.description
          @duplicate_algorithm_version.display_type = @original_algorithm_version.display_type
          @duplicate_algorithm_version.whole_tree_content_words_amount = @original_algorithm_version.whole_tree_content_words_amount
          @duplicate_algorithm_version.original_algorithm_version = @original_algorithm_version
          @duplicate_algorithm_version.backend_storage_type_id = ::AlgorithmVersions::BackendStorageTypes[:duplicate]
          # DOC: Duplicate version number is the save as in original number from which we making duplicate
          # at the same time number in original AlgorithmVersion gets updated by 1 each time its get updated
          @duplicate_algorithm_version.duplicate_algorithm_verion_version_number = @original_algorithm_version.original_algorithm_version_version_number
          @duplicate_algorithm_version.algorithm_tree_id = @original_algorithm_version.algorithm_tree_id
          @duplicate_algorithm_version.save(validate: false)
        end

        def create_duplicate_nodes
          binding.pry
          # DOC: We iterate from bottom of the tree up to root node
          # nodes = @original_algorithm_version.root_node.self_and_descendants.reverse
          nodes = @original_algorithm_version.root_node.self_and_descendants
          binding.pry
          @duplicate_nodes = []

          binding.pry
          nodes.each do |original_node|

            binding.pry
            create_duplicate_node(original_node)
          end
        end

        def present_in_duplicated_nodes?(original_node)
          select_duplicated_node(original_node).present?
        end

        def select_duplicated_node(original_node)
          @duplicate_nodes.select{|duplicate_node| duplicate_node.original_node_id == original_node.id }.first
        end

        def create_duplicate_node(original_node)
          binding.pry
          return if present_in_duplicated_nodes?(original_node)

          duplicate_node = original_node.type.constantize.public_send(:new)
          duplicate_node.type = original_node.type
          duplicate_node.position = original_node.position
          duplicate_node.title = original_node.title
          duplicate_node.instruction = original_node.instruction
          duplicate_node.step_finish_check = original_node.step_finish_check
          duplicate_node.solves_the_problem = original_node.solves_the_problem
          duplicate_node.sources = original_node.sources
          duplicate_node.additional_information = original_node.additional_information
          duplicate_node.note = original_node.note
          duplicate_node.step_functional_type = original_node.step_functional_type
          duplicate_node.control_structure_id = original_node.control_structure_id
          duplicate_node.control_structure_functional_type = original_node.control_structure_functional_type
          # linking with duplicate algorithm version
          duplicate_node.algorithm_version = @duplicate_algorithm_version
          duplicate_node.related_algorithm_version = @duplicate_algorithm_version
          duplicate_node.technologiable_type = original_node.technologiable_type
          duplicate_node.technologiable_id = original_node.technologiable_id

          # DOC: Warning! Recursion!
          # set parent
          binding.pry
          if original_node.parent.present?
            binding.pry
            if present_in_duplicated_nodes?(original_node.parent)
              binding.pry
              duplicate_node.parent = select_duplicated_node(original_node.parent)
            else
              binding.pry
              parent = create_duplicate_node(original_node.parent)
              duplicate_node.parent = parent
            end
          end

          duplicate_node.description = original_node.description
          duplicate_node.related_algorithm_version_id = @duplicate_algorithm_version.id
          duplicate_node.backend_storage_type_id = ::Nodes::BackendStorageTypes[:duplicate]
          duplicate_node.original_node_id = original_node.id
          @duplicate_nodes << duplicate_node
          duplicate_node
        end

        def create_introduction_step
          original_introduction_step = @original_algorithm_version.introduction_step
          introduction_step = @duplicate_algorithm_version.create_introduction_step
          introduction_step.title = original_introduction_step.title
          introduction_step.content = original_introduction_step.content
        end

      end
    end
  end
end