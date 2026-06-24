require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/technologies/memberable"
require "./app/services/concerns/technologies/nodes_linkable"

module Services
  module Algorithms
    module AlgorithmVersions
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include ::Services::Concerns::Technologies::Memberable
        include ::Services::Concerns::Technologies::NodesLinkable

        # DOC: This is version to track how much times algorithm version was
        # updated from one state to another state (differet description, amount of steps, content)
        DEFAULT_ORIGINAL_ALGORITHM_VERSION_VERSION_NUMBER = 1.freeze

        attr_reader :errors, :algorithm, :algorithm_tree, :root_leafe, :algorithm_version

        def initialize(params, algorithm)
          @params = params
          @algorithm = algorithm
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_algorithm_version

            binding.pry
            set_original_algorithm_version_version_number
            binding.pry
            link_nodes_with_algorithm_version

            binding.pry
            set_backend_storage_type_for_algorithm_version

            binding.pry
            @algorithm_version.save!


            binding.pry
            set_algorithm_version_display_type

            binding.pry
            create_algorithm_version_algorithm_tree

            binding.pry
            # DOC: should go strictly after create_algorithm_version_algorithm_tree method
            # if we will use it before we will not have algorithm_tree_id during duplication
            # of algorithm_version
            create_newest_duplicate_of_algorithm_version
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def technology
          @algorithm_version
        end

        def entity
          @algorithm_version
        end

        private

        def create_algorithm_version
          binding.pry
          @algorithm_version = @algorithm.algorithm_versions.new(@params)
        end

        def set_original_algorithm_version_version_number
          @algorithm_version.original_algorithm_version_version_number = DEFAULT_ORIGINAL_ALGORITHM_VERSION_VERSION_NUMBER
        end

        def create_newest_duplicate_of_algorithm_version
          binding.pry
          service = Services::Algorithms::AlgorithmVersions::CreateNewestDuplicateOfAlgorithmVersion.new(@algorithm_version)
          binding.pry
          service.call
          # TODO add error handling
          # TODO add this task into a background worker
        end

        def set_algorithm_version_display_type
          binding.pry
          # DOC: we taking first algorithm version as it's the only one
          # which is created by using Algorithm creation form
          service = Services::Algorithms::AlgorithmVersions::SetDisplayType.new(@algorithm_version)
          binding.pry
          service.call
          # TODO add error handling
        end

        def set_backend_storage_type_for_algorithm_version
          @algorithm_version.backend_storage_type_id = ::AlgorithmVersions::BackendStorageTypes[:original]
        end

        def create_algorithm_version_algorithm_tree
          binding.pry
          service = Services::Algorithms::Navigation::AlgorithmTrees::Create.new(@algorithm_version)
          service.call
          binding.pry
          if service.algorithm_tree.errors.present?
            @algorithm_tree = service.algorithm_tree
            raise ActiveRecord::RecordInvalid.new(service.algorithm_tree)
          end
        end

      end
    end
  end
end