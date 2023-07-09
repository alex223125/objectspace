module Services
  module Algorithms
    module Algorithms
      module Params
        class Create


          def initialize(params)
            @params = params
          end

          def call
            # binding.pry
            # 1 unsafe hash
            unsafe_params = @params.to_unsafe_h

            # 2 basic for new tree of strong params
            basic_tree = unsafe_params[:algorithms_algorithm]

            # 2. get all dynamic steps
            dynamic_steps = unsafe_params.select { |e| e.start_with? "dynamic_step" }

            # 3. attach each dynamic step to correct hashes
            dynamic_steps.each_with_index do |dynamic_step_params, index|
              # binding.pry
              parent_id_of_dynamic_step = dynamic_step_params[1]["substeps_attributes"]["0"]["parent_id_dynamic_step"]

              # binding.pry
              uniq_id_of_dynamic_step = dynamic_step_params[0] # dynamic_step_033135PM
              new_hash_with_id_from_iteration = { uniq_id_of_dynamic_step => dynamic_step_params[1]["substeps_attributes"]["0"] }
              child_node = new_hash_with_id_from_iteration

              # binding.pry
              attach_child_node_to_parent_node(basic_tree, parent_id_of_dynamic_step, child_node)
            end

            binding.pry
            basic_tree

            # PART 2 Move dynamic keys to full integer keys
            binding.pry
            dynamic_steps.each do |dynamic_step|
              binding.pry
              dynamic_key = dynamic_step[0]

              binding.pry
              new_hash = create_hash_with_numeric_key(basic_tree, dynamic_key)

              binding.pry
              parent_id_key = dynamic_step[1]["substeps_attributes"]["0"]["parent_id_dynamic_step"]

              binding.pry
              switch_hash_with_dynamic_key_on_hash_with_numeric_key(basic_tree, parent_id_key, dynamic_key, new_hash)
            end

            binding.pry
            basic_tree
            binding.pry
            unsafe_params[:algorithms_algorithm] = basic_tree

            binding.pry
            unsafe_params
          end

          private

          def attach_child_node_to_parent_node(tree_hash, parent_id_key, child_node)
            # binding.pry
            if tree_hash.respond_to?(:key?) && tree_hash.key?(parent_id_key)
              # binding.pry
              # Case 1.Adding to first substep element
              if parent_id_key.start_with?("dynamic_step")
                # binding.pry
                # 1 add substeps attributes key value pair
                if tree_hash[parent_id_key]["substeps_attributes"].present?
                  # do nothing
                else
                  tree_hash[parent_id_key]["substeps_attributes"] = {}
                end

                # 3 merge child
                # binding.pry
                tree_hash[parent_id_key]["substeps_attributes"].merge!(child_node)
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
                if substeps_second_level_step_params["substeps_attributes"].present?
                  # do nothing
                else
                  substeps_second_level_step_params["substeps_attributes"] = {}
                end
                # 3 merge child
                # binding.pry
                substeps_second_level_step_params["substeps_attributes"].merge!(child_node)
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
              key_without_prefix = tree_hash.keys[0].split("_")[2] # -> 094902
              {key_without_prefix => tree_hash.values[0]}
            elsif tree_hash.respond_to?(:each)
              r = nil
              tree_hash.find{ |*a| r=create_hash_with_numeric_key(a.last, parent_id_key) }
              r
            end
          end

          def switch_hash_with_dynamic_key_on_hash_with_numeric_key(tree_hash, parent_id_key, dynamic_key, new_hash)
              # binding.pry
              # parent_id_key.split("_")[2] - sometimes parent key already formatted to numbers and we will find it
              # only by number-key
              if tree_hash.respond_to?(:key?) && (tree_hash.key?(parent_id_key) || tree_hash.key?(parent_id_key.split("_")[2]))
                  # binding.pry
                  if parent_id_key.start_with?("dynamic_step")
                    binding.pry
                    # parent_id_key_from_tree = tree_hash.keys[0]
                    # 1 drop key
                    # tree_hash[parent_id_key_from_tree]["substeps_attributes"].delete(dynamic_key)
                    numeric_key = parent_id_key.split("_")[2]
                    tree_hash[numeric_key]["substeps_attributes"].delete(dynamic_key)
                    # assign new via merge!
                    tree_hash[numeric_key]["substeps_attributes"].merge!(new_hash)
                  else
                    # THIS ASE FOR ROOT STEP ONLY, EVERYTHING ELSE GOES VIA DYNAMIC STEP
                    # 1 drop key
                    # first iteration - whats why that long access
                    # S 1
                    # tree_hash[parent_id_key]["substeps_attributes"][parent_id_key]["substeps_attributes"].delete(dynamic_key)
                    # S 2
                    # binding.pry
                    tree_hash[parent_id_key]["substeps_attributes"].delete(dynamic_key)
                    # 2 assign new via merge!
                    # S 1
                    # tree_hash[parent_id_key]["substeps_attributes"][parent_id_key]["substeps_attributes"].merge!(new_hash)
                    # S 2
                    tree_hash[parent_id_key]["substeps_attributes"].merge!(new_hash)
                  end
              elsif tree_hash.respond_to?(:each)
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







