module Services
  module SimpleClasses
    module InterfaceGroups
      class Create

        attr_reader :errors, :interface_group, :target_simple_class

        def initialize(params, target_simple_class)
          @params = params
          @target_simple_class = target_simple_class
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_interface_group

            binding.pry
            link_with_simple_class

            link_with_root_interface_group
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

        def link_with_simple_class
          @interface_group.simple_class = @target_simple_class
        end

        def link_with_root_interface_group
          root = @target_simple_class.root_interface_group
          root.groups << @interface_group
          root.save
        end

        def set_functional_type
          binding.pry
          @interface_group.functional_type = ::InterfaceGroups::FunctionalTypes[:regular]
        end

      end
    end
  end
end