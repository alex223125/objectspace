module Services
  module Units
    module UnitVersions
      class Create

        attr_reader :errors, :unit_version

        def initialize(params)
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_version

            # binding.pry
            # set_unit_for_unit_usage_examples

            binding.pry
            @unit_version.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_version
          @unit_version = ::Units::UnitVersion.new(@params)
        end

        # by default each usage example create
        # during version creation assigned to unit versions
        # unit versions
        # def set_unit_for_unit_usage_examples
        #   binding.pry
        #   @unit_version.unit_usage_examples.each do |example|
        #     example.unit = @unit_version.unit
        #   end
        # end

      end
    end
  end
end