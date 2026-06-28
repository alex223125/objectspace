# service = Services::Algorithms::Navigation::AlgorithmTree::Create.new(Algorithms::AlgorithmVersion.last)
# service.call
# Algorithms::AlgorithmVersion.last.algorithm_tree.destroy

module Services
  module Algorithms
    module Navigation
      module AlgorithmTrees
        class Create

          attr_reader :errors, :algorithm_tree, :root_leafe

          def initialize(algorithm_version)
            @algorithm_version = algorithm_version
          end

          def call
            create_algorithm_tree
          end

          private

          def create_algorithm_tree
            binding.pry
            # @algorithm_tree = @algorithm_version.build_algorithm_tree
            @algorithm_tree = @algorithm_version.create_algorithm_tree

            binding.pry
            # DOC: root leaf just to hold all structure in one
            @root_leafe = @algorithm_tree.build_leafe
            @root_leafe.node_title = @algorithm_version.title

            binding.pry
            @root_leafe.position = 1
            @root_leafe.related_algorithm_version = @algorithm_version
            # TODO: Add this to separate root leafe and other leaves:
            # @root_leafe.native_functional_type = ROOT LEAFE
            # @root_leafe.save!

            binding.pry
            hash_tree = @algorithm_version.base_control_structure.hash_tree
            binding.pry
            add_layer_to_tree_structure(@root_leafe, hash_tree)

            ## Right order
            binding.pry
            @algorithm_version.algorithm_tree_id = @algorithm_tree.id
            @algorithm_version.save!
            binding.pry

            # # 1. Manually assign the algorithm_tree_id to all child leaves in memory
            # @algorithm_version.algorithm_tree.leafe.children.each do |leaf|
            #   leaf.algorithm_tree_id = @algorithm_tree.id
            # end

            # # 1. Define a quick block/lambda to recursively force the ID down the tree
            # assign_tree_id = ->(leaf, tree_id) do
            #   leaf.algorithm_tree_id = tree_id
            #   # If your Leaf model has an association to its children (e.g., has_many :children / :subleaves)
            #   # Loop through them in memory and apply the same tree_id
            #   if leaf.respond_to?(:children) && leaf.children.any?
            #     leaf.children.each { |child| assign_tree_id.call(child, tree_id) }
            #   end
            # end
            #
            # @algorithm_version.algorithm_tree.leafe.children do |top_leaf|
            #   assign_tree_id.call(top_leaf, @algorithm_tree.id)
            # end
            #
            # binding.pry
            # @algorithm_version.algorithm_tree.tree_root.self_and_descendants.each do |a|
            #   a.save!
            # end
            #
            # binding.pry
            #
            # @algorithm_version.save!
            #
            # @algorithm_version.algorithm_tree.leafe.children.each do |a|
            #   a.algorithm_tree_id = @algorithm_version.algorithm_tree.id
            #   # a.save!
            # end
            #
            # @algorithm_version.algorithm_tree.save!(validate: false)
            #
            # @algorithm_version.algorithm_tree.tree_root.save!
            # @algorithm_version.algorithm_tree.save!


            # 1. Define a robust depth-first recursive lambda to track and fix all nested nodes
            assign_tree_id_recursively = ->(leaf, target_tree_id) do
              return if leaf.nil?

              # Inject the missing database constraint identifier
              leaf.algorithm_tree_id = target_tree_id

              # If this node contains child arrays initialized in memory, process them
              if leaf.respond_to?(:children) && leaf.children.present?
                leaf.children.each do |child_leaf|
                  assign_tree_id_recursively.call(child_leaf, target_tree_id)
                end
              end
            end

            binding.pry
            # 2. Extract the true root container node
            root_leaf = @algorithm_version.algorithm_tree.tree_root


            binding.pry
            # 3. Fire the recursive assignment across the memory tree graph
            if root_leaf
              assign_tree_id_recursively.call(root_leaf, @algorithm_version.algorithm_tree.id)
            end

            binding.pry
            # 4. Bind version mappings and save down the whole pipeline safely
            # @algorithm_version.original_algorithm_version_id = @algorithm_version.algorithm_tree.id
            @algorithm_version.algorithm_tree_id = @algorithm_tree.id


            binding.pry
            @algorithm_version.algorithm_tree.tree_root.save!

            binding.pry
            @algorithm_version.save!

            binding.pry
            # @algorithm_tree.save!


            latest_duplicate_algorithm_version = @algorithm_version.latest_duplicate_algorithm_version
            latest_duplicate_algorithm_version.algorithm_tree_id = @algorithm_tree.id
            latest_duplicate_algorithm_version.save!
            binding.pry


          rescue ActiveRecord::RecordInvalid => e
            binding.pry
            @errors = e.message
            Rails.logger.error(@errors)
          end

          def add_layer_to_tree_structure(parent_node, layer)
            binding.pry
            layer.each do |tree_layer|
              # 1.find node to which we will reference leafe
              binding.pry
              referencable_node = tree_layer.first
              # 2.find its children
              binding.pry
              children = tree_layer.second
              # 3.create new child node from leafe
              child_node = parent_node.children.new
              # 4.build child node
              binding.pry
              child_node.referencable = referencable_node
              child_node.position = referencable_node.position
              # new_leafe.parent_id = node.parent_id
              child_node.node_title = referencable_node.title
              binding.pry

              # DOC: Initial control structure directly associated with algorithm_version, and
              # in that case we don't have related_algorithm_version_id.
              # In other cases we take related_algorithm_version_id
              if referencable_node.control_structure_functional_type == ControlStructures::FunctionalTypes[:initial_template]
                child_node.algorithm_version_id = referencable_node.algorithm_version_id
              else
                child_node.related_algorithm_version_id = referencable_node.related_algorithm_version_id
              end


              # Set description or note
              if ::Steps::FunctionalTypes[referencable_node.step_functional_type] == "regular"
                child_node.node_description = referencable_node.description
              elsif ::Steps::FunctionalTypes[referencable_node.step_functional_type] == "wrapper" ||
                  ::Steps::FunctionalTypes[referencable_node.step_functional_type] == "container"
                child_node.node_note = referencable_node.note
              end

              # Set referenced entity functional type
              # DOC: node represents or Step or ControlStructure
              if referencable_node.step_functional_type.present?
                step_functional_type_name = ::Steps::FunctionalTypes[referencable_node.step_functional_type]
                leafe_functional_type_id = ::AlgorithmsNavigation::AlgorithmTrees::ReferencedStepFunctionalTypes[step_functional_type_name]
                child_node.referenced_step_functional_type  = leafe_functional_type_id
              elsif referencable_node.control_structure_functional_type.present?
                control_structure_functional_type_name = ::ControlStructures::FunctionalTypes[referencable_node.control_structure_functional_type]
                leafe_functional_type_id = ::AlgorithmsNavigation::AlgorithmTrees::ReferencedControlStructureFunctionalTypes[control_structure_functional_type_name]
                child_node.referenced_control_structure_functional_type  = leafe_functional_type_id
              end

              # child_node.save!

              # 5.save child node
              # DOC: All errors related to children entities will be attached
              # to algorithm_tree instance
              # @algorithm_tree.save!

              # binding.pry
              # child_node.save
              # 4. recursevly repeat for each children
              if children.any?

                binding.pry
                # new_parent_node = ::Algorithms::Navigation::Leafe.new
                # new_parent_node.parent = parent_node
                # new_parent_node.save
                # new_parent_node = parent_node.subleaves.new

                binding.pry
                add_layer_to_tree_structure(child_node, children)
              end

              # children.each do |child_layer|
              #   binding.pry
              #   new_parent_node = parent_node.children.new
              #
              #   binding.pry
              #   add_layer_to_tree_structure(new_parent_node, child_layer)
              # end
            end
          end

        end
      end
    end
  end
end