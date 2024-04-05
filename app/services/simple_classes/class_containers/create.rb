module Services
  module SimpleClasses
    module ClassContainers
      class Create

        attr_reader :errors, :class_container

        def initialize(params, target_place, current_user)
          @params = params
          @target_place = target_place
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_class_container

            binding.pry
            set_creator

            binding.pry
            set_place

            binding.pry
            set_related_simple_class

            binding.pry
            set_functional_type

            binding.pry
            @class_container.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_class_container
          @class_container = ::SimpleClasses::ClassContainer.new(@params)
        end

        def set_creator
          binding.pry
          @class_container.creator = @current_user
        end

        def set_place
          binding.pry
          if @target_place.class == ::SimpleClasses::SimpleClass
            # DOC: In case of SimpleClass we putting new container in "invisible for user" root container
            @class_container.parent = @target_place.root_class_container
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            @class_container.parent = @target_place
          end
        end

        def set_related_simple_class
          binding.pry
          # DOC: much effective to have 1 step access then each time retrive whole tree
          if @target_place.class == ::SimpleClasses::SimpleClass
            @class_container.related_simple_class = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            @class_container.related_simple_class = @target_place.root.simple_class
          end
        end

        def set_functional_type
          @class_container.functional_type = ::ClassContainers::FunctionalTypes[:regular]
        end

      end
    end
  end
end
