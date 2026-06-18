require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/technologies/memberable"
require "./app/services/concerns/technologies/nodes_linkable"
require "./app/services/concerns/shared/owner_permissionable"


module Services
  module Algorithms
    module Algorithms
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include ::Services::Concerns::Technologies::Memberable
        include ::Services::Concerns::Technologies::NodesLinkable
        include ::Services::Concerns::Shared::OwnerPermissionable

        # DOC: This is version to track how much times algorithm version was
        # updated from one state to another state (differet description, amount of steps, content)
        DEFAULT_ORIGINAL_ALGORITHM_VERSION_VERSION_NUMBER = 1.freeze

        attr_reader :errors, :algorithm, :algorithm_tree, :root_leafe, :permission

        def initialize(params, target_place, owner, creator)
          @params = params
          @target_place = target_place
          @owner = owner
          @creator = creator
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_algorithm

            binding.pry
            set_visibility

            binding.pry
            set_place
            set_owner
            set_creator

            set_tags

            binding.pry
            set_functional_type

            binding.pry
            # link_with_interface_group if @target_interface_group.present?

            # @algorithm.save(validate: false)
            binding.pry
            set_default_version
            set_original_algorithm_version_version_number
            set_backend_storage_type_for_algorithm_version
            binding.pry
            link_nodes_with_algorithm_version

            binding.pry
            @algorithm.save!


            binding.pry
            set_algorithm_version_display_type

            binding.pry
            create_algorithm_version_algorithm_tree

            binding.pry
            # DOC: should go strictly after create_algorithm_version_algorithm_tree method
            # if we will use it before we will not have algorithm_tree_id during duplication
            # of algorithm_version
            create_newest_duplicate_of_algorithm_version

            binding.pry
            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def technology
          @algorithm
        end

        def entity
          @algorithm
        end

        private

        def create_algorithm
          binding.pry
          @algorithm = ::Algorithms::Algorithm.new(@params.except(:tag_list, :functional_type))
        end

        def set_visibility
          binding.pry
          @algorithm.visibility_status = ::Algorithms::VisibilityStatusTypes[:public]
        end

        def set_functional_type
          binding.pry
          functional_type = @params[:functional_type]
          if functional_type == "class_level"
            @algorithm.functional_type = ::Algorithms::FunctionalTypes[:class_level]
          else
            # DOC: if we not passing functional_type in request, means we have regular algorithm
            @algorithm.functional_type = ::Algorithms::FunctionalTypes[:regular]
          end
        end

        def set_original_algorithm_version_version_number
          default_algorithm_version = @algorithm.default_version
          default_algorithm_version.original_algorithm_version_version_number = DEFAULT_ORIGINAL_ALGORITHM_VERSION_VERSION_NUMBER
        end

        def set_default_version
          binding.pry
          @algorithm.default_version = @algorithm.algorithm_versions.first
          # @algorithm.default_version_id = @algorithm.algorithm_versions.first.id
          # @algorithm.save(validate: false)
        end


        def create_newest_duplicate_of_algorithm_version
          binding.pry
          algorithm_version = @algorithm.default_version
          service = Services::Algorithms::AlgorithmVersions::CreateNewestDuplicateOfAlgorithmVersion.new(algorithm_version)
          binding.pry
          service.call
          # TODO add error handling
          # TODO add this task into a background worker
        end

        def set_algorithm_version_display_type
          binding.pry
          # DOC: we taking first algorithm version as it's the only one
          # which is created by using Algorithm creation form
          service = Services::Algorithms::AlgorithmVersions::SetDisplayType.new(algorithm_version)
          binding.pry
          service.call
          # TODO add error handling
        end

        def set_backend_storage_type_for_algorithm_version
          algorithm_version.backend_storage_type_id = ::AlgorithmVersions::BackendStorageTypes[:original]
        end

        def algorithm_version
          @algorithm_version ||= @algorithm.algorithm_versions.first
        end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @algorithm.folder = @target_place
          elsif @target_place.class == Repository
            @algorithm.repository = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            binding.pry
            container_member = create_container_member
            binding.pry
            @algorithm.class_containers << container_member
          elsif @target_place.class == ::SimpleClasses::InterfaceGroup
            binding.pry
            interface_member = create_interface_member
            binding.pry
            @algorithm.interface_members << interface_member
          elsif @target_place.class == ::Frameworks::FrameworkInterface
            @algorithm.framework_interface = @target_place
          elsif @target_place.class == ::SimpleClasses::SimpleClassInterface
            @algorithm.simple_class_interface = @target_place
          end
        end

        def set_owner
          binding.pry
          @algorithm.ownerable = @owner
        end

        def set_creator
          @algorithm.creator = @creator
        end

        def create_algorithm_version_algorithm_tree
          binding.pry
          algorithm_version = @algorithm.default_version

          # a = Algorithms::AlgorithmVersion.all
          # a.each do |algorithm_version|
          #   algorithm_version.algorithm_tree_id = nil
          #   service = Services::Algorithms::Navigation::AlgorithmTrees::Create.new(algorithm_version)
          #   service.call
          #   algorithm_version.algorithm_tree_id = service.algorithm_tree.id
          #   algorithm_version.save!
          # end
          service = Services::Algorithms::Navigation::AlgorithmTrees::Create.new(algorithm_version)
          service.call
          binding.pry
          if service.algorithm_tree.errors.present?
            @algorithm_tree = service.algorithm_tree
            raise ActiveRecord::RecordInvalid.new(service.algorithm_tree)
          end
          # if service.root_leafe.errors.present?
          #   @root_leafe = service.root_leafe
          #   raise ActiveRecord::RecordInvalid.new(service.root_leafe)
          # end
        end
      end
    end
  end
end