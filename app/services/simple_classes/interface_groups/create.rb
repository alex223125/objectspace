module Services
  module SimpleClasses
    module InterfaceGroups
      class Create

        attr_reader :errors, :interface_group

        def initialize(params, target_place, creator, owner)
          @params = params
          @target_place = target_place
          @creator = creator
          @owner = owner
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_interface_group

            set_creator
            set_related_simple_class

            binding.pry
            # link_with_simple_class
            set_target_place
            set_related_class_container

            # link_with_root_interface_group
            set_functional_type

            binding.pry
            @interface_group.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_interface_group
          binding.pry
          @interface_group = ::SimpleClasses::InterfaceGroup.new(@params)
        end

        def set_target_place
          if @target_place.class == ::SimpleClasses::InterfaceGroup
            @interface_group.parent = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            @interface_group.class_container = @target_place
          end
        end

        def set_creator
          binding.pry
          @interface_group.creator = @creator
        end

        def set_related_simple_class
          binding.pry
          if @target_place.closest_simple_class.present?
            @interface_group.related_simple_class = @target_place.closest_simple_class
          elsif @target_place.closest_framework.present?
            @interface_group.related_framework = @target_place.closest_framework
          end
        end

        def set_related_class_container
          if @target_place.class == ::SimpleClasses::InterfaceGroup
            @interface_group.related_class_container = @target_place.root.class_container
          end
        end

        # TODO: No need we alreadyt definint parent interface_group in set_target_place
        # def link_with_root_interface_group
        #   root = @target_simple_class.root_interface_group
        #   root.groups << @interface_group
        #   root.save
        # end

        def set_functional_type
          binding.pry
          if @target_place.class == ::SimpleClasses::InterfaceGroup
            @interface_group.functional_type = ::InterfaceGroups::FunctionalTypes[:regular]
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            @interface_group.functional_type = ::InterfaceGroups::FunctionalTypes[:class_container_root]
          end
        end

      end
    end
  end
end