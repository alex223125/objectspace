module Services
  module SimpleClasses
    module ClassContainers
      class BuildRootContainer
        ROOT_CONTAINER_DEFAULT_NAME = "Main".freeze

        attr_reader :errors, :class_container

        def initialize(creator)
          @creator = creator
          # @related_simple_class = related_simple_class
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_class_container

            binding.pry
            set_creator
            set_functional_type

            # set_related_simple_class

            binding.pry
            # @class_container.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
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

        # def set_related_simple_class
        #   binding.pry
        #   @class_container.related_simple_class = @related_simple_class
        # end
      end
    end
  end
end
