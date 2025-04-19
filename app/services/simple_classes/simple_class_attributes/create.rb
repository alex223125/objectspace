module Services
  module SimpleClasses
    module SimpleClassAttributes
      class Create

        attr_reader :errors, :simple_class_attribute

        def initialize(params, creator, owner)
          @params = params
          @creator = creator
          @owner = owner
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_simple_class_attribute

            set_creator
            set_owner

            binding.pry
            @simple_class_attribute.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_simple_class_attribute
          binding.pry
          @simple_class_attribute = ::SimpleClasses::SimpleClassAttribute.new(@params)
        end

        def set_creator
          binding.pry
          @simple_class_attribute.creator = @creator
        end

        def set_owner
          binding.pry
          @simple_class_attribute.ownerable = @owner
        end

      end
    end
  end
end