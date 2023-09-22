module Algorithm
  module Concerns
    module Subnodable
      extend ActiveSupport::Concern

      def recursive_nested_substeps_attr
        build_recursive_params(
          recursive_key: 'subnodes_attributes',
          parameters: @params,
          permitted_attributes: [:technologiable_type,
                                 :technologiable_id,

                                 :id,

                                 :position,
                                 :type,
                                 :title,
                                 :instruction,
                                 :step_finish_check,
                                 :solves_the_problem,
                                 :sources,
                                 :additional_information,

                                 :step_functional_type,
                                 :control_structure_functional_type,
                                 :note,
                                 :description,

                                 :_destroy,

                                 conditions_attributes: [:id, :title, :instruction],
                                 attachments_attributes: [:id, :attachable_id,
                                                          :attachable_type, :_destroy]]
        )
      end

    end
  end
end
