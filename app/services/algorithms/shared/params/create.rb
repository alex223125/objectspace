module Services
  module Algorithms
    module Shared
      module Params
        class Create

          TYPES_MAPPING = {
            algorithm_creation: {params_root_key: :algorithms_algorithm},
            algorithm_version_create: {params_root_key: :algorithms_algorithm_version},
            algorithm_version_update: {params_root_key: :algorithms_algorithm_version},

            simple_algorithm_version_creation: {params_root_key: :algorithms_algorithm}
          }.freeze


          def initialize(params, action_type)
            @params = params
            @action_type = action_type
          end

          def call
            # binding.pry
            # 1 unsafe hash
            unsafe_params = @params.to_unsafe_h

            # 2 basic for new tree of strong params
            # basic_tree = unsafe_params[:algorithms_algorithm]
            basic_tree = unsafe_params[TYPES_MAPPING[@action_type][:params_root_key]]


            # 2. get all dynamic steps
            # binding.pry
            dynamic_nodes = unsafe_params.select { |e| e.start_with? "dynamic_node" }

            # 3. attach each dynamic step to correct hashes
            dynamic_nodes.each_with_index do |dynamic_node_params, index|
              # binding.pry
              # parent_id_of_dynamic_node = dynamic_node_params[1]["substeps_attributes"]["0"]["parent_id_dynamic_node"]
              parent_id_of_dynamic_node = dynamic_node_params[1]["subnodes_attributes"]["0"]["parent_id_dynamic_node"]

              # binding.pry
              uniq_id_of_dynamic_node = dynamic_node_params[0] # dynamic_node_033135PM
              # new_hash_with_id_from_iteration = { uniq_id_of_dynamic_node => dynamic_node_params[1]["substeps_attributes"]["0"] }
              new_hash_with_id_from_iteration = { uniq_id_of_dynamic_node => dynamic_node_params[1]["subnodes_attributes"]["0"] }
              child_node = new_hash_with_id_from_iteration

              # binding.pry
              attach_child_node_to_parent_node(basic_tree, parent_id_of_dynamic_node, child_node)
            end

            binding.pry
            basic_tree

            # PART 2 Move dynamic keys to full integer keys
            # binding.pry
            dynamic_nodes.each do |dynamic_node|
              # binding.pry
              dynamic_key = dynamic_node[0]

              # binding.pry
              new_hash = create_hash_with_numeric_key(basic_tree, dynamic_key)

              # binding.pry
              parent_id_key = dynamic_node[1]["subnodes_attributes"]["0"]["parent_id_dynamic_node"]
              # parent_id_key = dynamic_node[1]["substeps_attributes"]["0"]["parent_id_dynamic_node"]

              # binding.pry
              switch_hash_with_dynamic_key_on_hash_with_numeric_key(basic_tree, parent_id_key, dynamic_key, new_hash)
            end

            binding.pry
            # parse_attachments(basic_tree)

            basic_tree
            # binding.pry
            unsafe_params[TYPES_MAPPING[@action_type][:params_root_key]] = basic_tree

            # binding.pry
            unsafe_params
          end

          private

          def attach_child_node_to_parent_node(tree_hash, parent_id_key, child_node)
            # binding.pry
            if tree_hash.respond_to?(:key?) && tree_hash.key?(parent_id_key)
              # binding.pry
              # Case 1.Adding to first substep element
              if parent_id_key.start_with?("dynamic_node")
                # binding.pry
                # 1 add substeps attributes key value pair
                # if tree_hash[parent_id_key]["substeps_attributes"].present?
                if tree_hash[parent_id_key]["subnodes_attributes"].present?
                  # do nothing
                else
                  tree_hash[parent_id_key]["subnodes_attributes"] = {}
                end

                # 3 merge child
                # binding.pry
                tree_hash[parent_id_key]["subnodes_attributes"].merge!(child_node)
              else
                # binding.pry

                # Solutiuin 1
                # # In this case parent id key something like this 1686339074469
                # # 1 Go to second level substeps params
                # first_level_steps_params = tree_hash[parent_id_key]
                # substeps_second_level_step_params = first_level_steps_params["substeps_attributes"][parent_id_key]

                # Solutiuin 2
                # rename variable
                substeps_second_level_step_params = tree_hash[parent_id_key]

                # 2 add substeps attributes key value pair
                if substeps_second_level_step_params["subnodes_attributes"].present?
                  # do nothing
                else
                  substeps_second_level_step_params["subnodes_attributes"] = {}
                end
                # 3 merge child
                # binding.pry
                substeps_second_level_step_params["subnodes_attributes"].merge!(child_node)
              end
            elsif tree_hash.respond_to?(:each)
              r = nil
              tree_hash.find{ |*a| r=attach_child_node_to_parent_node(a.last, parent_id_key, child_node) }
              r
            end
          end


          def create_hash_with_numeric_key(tree_hash, parent_id_key)
            # binding.pry
            if tree_hash.respond_to?(:key?) && tree_hash.key?(parent_id_key)
              # binding.pry
              # TODO: here we should have only dynamic keys, somehow not dynamic key-value par got there during update algorthm scenario
              # ["0", "dynamic_node_011824", "dynamic_node_011835"]
              # if tree_hash.keys[0].start_with?("dynamic_node")
              #   key_without_prefix = tree_hash.keys[0].split("_")[2] # -> 011824
              # else
              #   key_without_prefix = tree_hash.keys[0] # -> "0"
              # end

              # 1
              key_without_prefix = parent_id_key.split("_")[2]

              # 2
              # {key_without_prefix => tree_hash.values[0]}
              {key_without_prefix => tree_hash[parent_id_key]}
            elsif tree_hash.respond_to?(:each)
              r = nil
              tree_hash.find{ |*a| r=create_hash_with_numeric_key(a.last, parent_id_key) }
              r
            end
          end

          # def parse_attachments(tree_hash)
          #   if tree_hash.respond_to?(:key?) && (tree_hash["type"] == "Algorithms::Nodes::Step")
          #     binding.pry
          #     attachments = JSON.parse(tree_hash[:attachments][0])
          #     attachments_attributes = []
          #     attachments.each_with_index do |attachment, index|
          #       attachments_attributes << {"attachable_id" => attachment["value"], "attachable_type" => attachment["type"]}
          #       # attachments_attributes << {"attachable_id" => attachment["value"]}
          #     end
          #     tree_hash.merge!({"attachments_attributes" => attachments_attributes})
          #   elsif tree_hash.respond_to?(:each)
          #     r = nil
          #     tree_hash.find{ |*a| r=parse_attachments(a.last) }
          #     r
          #   end
          # end

          def switch_hash_with_dynamic_key_on_hash_with_numeric_key(tree_hash, parent_id_key, dynamic_key, new_hash)
              # binding.pry
              # parent_id_key.split("_")[2] - sometimes parent key already formatted to numbers and we will find it
              # only by number-key
              # binding.pry
              if tree_hash.respond_to?(:key?) && (tree_hash.key?(parent_id_key) || tree_hash.key?(parent_id_key.split("_")[2]))
                  # binding.pry
                  if parent_id_key.start_with?("dynamic_node")
                    # binding.pry
                    # parent_id_key_from_tree = tree_hash.keys[0]
                    # 1 drop key
                    # tree_hash[parent_id_key_from_tree]["substeps_attributes"].delete(dynamic_key)
                    # binding.pry
                    numeric_key = parent_id_key.split("_")[2]
                    tree_hash[numeric_key]["subnodes_attributes"].delete(dynamic_key)
                    # assign new via merge!
                    tree_hash[numeric_key]["subnodes_attributes"].merge!(new_hash)
                  else
                    # THIS STEP FOR ROOT STEP ONLY, EVERYTHING ELSE GOES VIA DYNAMIC STEP
                    # 1 drop key
                    # first iteration - whats why that long access
                    # S 1
                    # tree_hash[parent_id_key]["substeps_attributes"][parent_id_key]["substeps_attributes"].delete(dynamic_key)
                    # S 2
                    # binding.pry
                    tree_hash[parent_id_key]["subnodes_attributes"].delete(dynamic_key)
                    # 2 assign new via merge!
                    # S 1
                    # tree_hash[parent_id_key]["substeps_attributes"][parent_id_key]["substeps_attributes"].merge!(new_hash)
                    # S 2
                    # binding.pry
                    tree_hash[parent_id_key]["subnodes_attributes"].merge!(new_hash)
                  end
              elsif tree_hash.respond_to?(:each)
                # binding.pry
                r = nil
                tree_hash.find{ |*a| r=switch_hash_with_dynamic_key_on_hash_with_numeric_key(a.last, parent_id_key, dynamic_key, new_hash) }
                r
              end
           end



        end
      end
    end
  end
end







