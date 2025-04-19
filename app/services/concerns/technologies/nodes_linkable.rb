module Services
  module Concerns
    module Technologies
      module NodesLinkable

        def link_nodes_with_algorithm_version
          if entity.class == ::Algorithms::AlgorithmVersion
            algorithm_version = entity
          elsif entity.class == ::Algorithms::Algorithm
            algorithm_version = entity.default_version
          end
          binding.pry
          # base_control_structure = algorithm_version.base_control_structure
          initial_template_type = ControlStructures::FunctionalTypes[:initial_template]
          base_control_structure = algorithm_version
                                       .control_structures
                                       .select{|structure| structure.control_structure_functional_type == initial_template_type }
                                       .first
          # binding.pry
          # all_nodes = base_control_structure.self_and_descendants
          all_nodes = collect_all_subnodes(base_control_structure)
          binding.pry
          all_nodes.flatten.each do |node|
            node.related_algorithm_version = algorithm_version
            # node.save(validate: false)
          end
        end

        private

        def collect_all_subnodes(node)
          all_nodes = []
          binding.pry
          put_nodes_in_bunch(all_nodes, node)
        end

        def put_nodes_in_bunch(all_nodes, node)
          subnodes = node.subnodes
          if subnodes.any?
            all_nodes << subnodes.to_a
            subnodes.each do |subnode|
              put_nodes_in_bunch(all_nodes, subnode)
            end
          end
          all_nodes
        end

      end
    end
  end
end