module Services
  module Units
    module Units
      class Create

        attr_reader :errors, :unit

        def initialize(params)
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_unit

            binding.pry
            set_usage_unit_example_flag

            binding.pry
            set_visibility

            binding.pry
            @unit.save!

            binding.pry
            set_default_version
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_unit
          binding.pry
          @unit = ::Units::Unit.new(@params)
        end

        def set_usage_unit_example_flag
          binding.pry
          @unit.unit_usage_examples.each do |example|
            example.is_for_all_unit_versions = true
          end
        end

        def set_visibility
          binding.pry
          @unit.visibility_status = ::Units::VisibilityStatusTypes[:public]
        end

        def set_default_version
          binding.pry
          @unit.default_version_id = @unit.unit_versions.first.id
          @unit.save!
        end

      end
    end
  end
end