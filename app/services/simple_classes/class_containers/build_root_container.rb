module Services
  module SimpleClasses
    module ClassContainers
      class BuildRootContainer
        ROOT_CONTAINER_DEFAULT_NAME = "Main".freeze

        attr_reader :errors, :class_container

        def initialize(creator, target_entity)
          @creator = creator
          @target_entity = target_entity
          # @related_simple_class = related_simple_class
        end

        def call
          # ActiveRecord::Base.transaction do
          binding.pry
          create_class_container

          binding.pry
          set_creator
          set_functional_type

          set_target_entity
          # set_related_simple_class

          binding.pry
            # @class_container.save!
          # end
        # rescue ActiveRecord::RecordInvalid => e
        #   @errors = e.message
        #   Rails.logger.error(@errors)
        end

        private

        def create_class_container
          @class_container = ::SimpleClasses::ClassContainer.new(title: ROOT_CONTAINER_DEFAULT_NAME)
        end

        def set_functional_type
          @class_container.functional_type = ::ClassContainers::FunctionalTypes[:root_class_container]
        end

        def set_creator
          binding.pry
          @class_container.creator = @creator
        end

        def set_target_entity
          if @target_entity.class == ::SimpleClasses::SimpleClass
            @class_container.simple_class = @target_entity
          elsif @target_entity.class == ::Frameworks::Framework
            @class_container.framework = @target_entity
          end
        end
      end
    end
  end
end
