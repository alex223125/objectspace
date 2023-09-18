module Services
  module SimpleClasses
    module SimpleClassAttributes
      class Update

        attr_reader :errors, :simple_class_attribute

        def initialize(params, simple_class_attribute)
          @params = params
          @simple_class_attribute = simple_class_attribute
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            update_simple_class_attribute

            binding.pry
            set_actions

            binding.pry
            @simple_class_attribute.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def update_simple_class_attribute
          @simple_class_attribute.assign_attributes(@params.except(:actions))
        end

        def set_actions
          binding.pry
          if @params[:actions].present?
            array = JSON.parse(@params[:actions])

            unit_type = "Units::Unit"
            units_hashes = array.select{|action| action["type"] == unit_type}
            units_ids = units_hashes.map{|h| h["value"]}
            units = ::SimpleClasses::InterfaceMember.where(memberable_id: units_ids, memberable_type: unit_type)

            algorithm_type = "Algorithms::Algorithm"
            algorithm_hashes = array.select{|action| action["type"] == algorithm_type}
            algorithms_ids = algorithm_hashes.map{|h| h["value"]}
            algorithms = ::SimpleClasses::InterfaceMember.where(memberable_id: algorithms_ids, memberable_type: algorithm_type)

            combined_array = units.to_a + algorithms.to_a
            @simple_class_attribute.actions << combined_array
          end
        end

      end
    end
  end
end
