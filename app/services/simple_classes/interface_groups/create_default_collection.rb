module Services
  module SimpleClasses
    module InterfaceGroups
      class CreateDefaultCollection

        GROUPS_MAP = {
          decision_process_object_class: [{title: "Creation actions", description: "creation actions description"},
                                          {title: "Modification actions", description: "Modification faasfasdasfasfsfaf"},
                                          {title: "Estimation actions", description: "Estimation asfsfasdasfasfsfaf"},
                                          {title: "Validation actions", description: "Validation asfasfsasdasfasfsfaf"},
                                          {title: "Retrospective analysis actions", description: "Retrospective affsaasdasfasfsfaf"},
                                          {title: "Prediction actions", description: "Prediction fasfsfasdasfasfsfaf"}
          ]
        }.freeze

        def initialize(class_type)
          @class_type = class_type
        end

        def call
          result = []
          GROUPS_MAP[@class_type].each do |params|
            result << create(params)
          end
          result
        end

        private

        def create(params)
          ::SimpleClasses::InterfaceGroup.new(title: params[:title], description: params[:description])
        end

      end
    end
  end
end
