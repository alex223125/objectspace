module Services
  module Algorithms
    module Algorithms
      class Create

        attr_reader :errors, :algorithm

        def initialize(params)
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_algorithm

            binding.pry
            set_visibility

            binding.pry
            @algorithm.save!

            binding.pry
            set_default_version
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_algorithm
          binding.pry
          @algorithm = ::Algorithms::Algorithm.new(@params)
        end

        def set_visibility
          binding.pry
          @algorithm.visibility_status = ::Algorithms::VisibilityStatusTypes[:public]
        end

        def set_default_version
          binding.pry
          @algorithm.default_version_id = @algorithm.algorithm_versions.first.id
          @algorithm.save!
        end

      end
    end
  end
end