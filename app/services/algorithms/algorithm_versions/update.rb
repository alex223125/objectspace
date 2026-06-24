require "./app/services/concerns/technologies/nodes_linkable"

module Services
  module Algorithms
    module AlgorithmVersions
      class Update
        include ::Services::Concerns::Technologies::NodesLinkable

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
            link_nodes_with_algorithm_version

            binding.pry
            link_control_structures_with_algorithm_version

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

        def entity
          @algorithm_version
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
          binding.pry
          # @algorithm_version.assign_attributes(@params)

          # Dig past 'algorithm_versions_attributes' and the index '0'
          version_attributes = @params.dig("algorithm_versions_attributes", "0")

          if version_attributes.present?
            @algorithm_version.assign_attributes(version_attributes)
          else
            # Fallback if the payload is structured directly
            @algorithm_version.assign_attributes(@params)
          end
        end

        def update_original_algorithm_version_version_number
          binding.pry
          set_zero_original_algorithm_version_version_number if @algorithm_version.original_algorithm_version_version_number == nil
          @algorithm_version.original_algorithm_version_version_number = @algorithm_version.original_algorithm_version_version_number + DEFAULT_ALGORITHM_VERSION_INCREMENT_VALUE
        end

        def set_zero_original_algorithm_version_version_number
          # Case: When we creating using wizard form
          # So we use update service for create purpose
          @algorithm_version.original_algorithm_version_version_number = 0
        end

      end
    end
  end
end
