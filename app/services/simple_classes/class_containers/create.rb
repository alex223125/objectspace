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
            set_related_class_layer_entity

            binding.pry
            set_functional_type
            set_to_which_structure_belongs

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
          if @target_place.class == ::SimpleClasses::SimpleClass || @target_place.class == ::Frameworks::Framework
            # DOC: In case of SimpleClass or Framework we putting new container in "invisible for user" root container
            @class_container.parent = @target_place.root_class_container
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            @class_container.parent = @target_place
          end
        end

        def set_related_class_layer_entity
          binding.pry
          # DOC: much effective to have 1 step access then each time retrive whole tree
          if @target_place.class == ::SimpleClasses::ClassContainer
            @class_container.related_simple_class = @target_place.root.simple_class
          elsif @target_place.class == ::SimpleClasses::SimpleClass
            @class_container.related_simple_class = @target_place
          elsif @target_place.class == ::Frameworks::Framework
            @class_container.related_framework = @target_place
          end
        end

        def set_functional_type
          @class_container.functional_type = ::ClassContainers::FunctionalTypes[:regular]
        end

        def set_to_which_structure_belongs
          if @target_place.class == ::SimpleClasses::SimpleClass
            @class_container.belongs_to_structure_type = ::ClassContainers::BelongsToStructureTypes[:belongs_to_simple_class]
          elsif @target_place.class == ::Frameworks::Framework
            @class_container.belongs_to_structure_type = ::ClassContainers::BelongsToStructureTypes[:belongs_to_framework]
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            class_layer_entity = @target_place.closest_class_layer_entity
            if class_layer_entity.class == ::SimpleClasses::SimpleClass
              @class_container.belongs_to_structure_type = ::ClassContainers::BelongsToStructureTypes[:belongs_to_simple_class]
            elsif class_layer_entity.class == ::Frameworks::Framework
              @class_container.belongs_to_structure_type = ::ClassContainers::BelongsToStructureTypes[:belongs_to_framework]
            end
          end
        end

        # module ClassContainers
        #   class BelongsToStructureTypes < ActiveEnum::Base
        #     value :id => 1, :name => :belongs_to_simple_class
        #     value :id => 2, :name => :belongs_to_framework
        #   end
        # end

      end
    end
  end
end
