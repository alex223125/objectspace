module Services
  module Algorithms
    module AlgorithmVersions
      class Update

        DEFAULT_ALGORITHM_VERSION_INCREMENT_VALUE = 1.freeze

        attr_reader :errors, :algorithm_version

        def initialize(algorithm_version, params)
          @algorithm_version = algorithm_version
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            update_algorithm_verion

            binding.pry
            update_original_algorithm_version_version_number

            binding.pry
            @algorithm_version.save!

            binding.pry
            create_newest_duplicate_of_algorithm_version
          end
        rescue ActiveRecord::RecordInvalid => e
          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_newest_duplicate_of_algorithm_version
          binding.pry
          service = Services::Algorithms::AlgorithmVersions::CreateNewestDuplicateOfAlgorithmVersion.new(@algorithm_version)
          service.call
          # TODO add error handling
          # TODO add this task into a background worker
        end

        def update_algorithm_verion
          @algorithm_version.assign_attributes(@params)
        end

        def update_original_algorithm_version_version_number
          @algorithm_version.original_algorithm_version_version_number = @algorithm_version.original_algorithm_version_version_number + DEFAULT_ALGORITHM_VERSION_INCREMENT_VALUE
        end

      end
    end
  end
end
