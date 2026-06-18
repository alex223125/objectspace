require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/technologies/memberable"
require "./app/services/concerns/shared/owner_permissionable"

module Services
  module Articles
    module Articles
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include ::Services::Concerns::Technologies::Memberable
        include ::Services::Concerns::Shared::OwnerPermissionable

        attr_reader :errors, :article, :permission

        def initialize(params, target_place, creator, owner)
          @params = params
          @target_place = target_place
          @owner = owner
          @creator = creator
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_article

            binding.pry
            set_visibility

            binding.pry
            set_place

            binding.pry
            set_owner
            set_creator

            binding.pry
            set_tags

            binding.pry
            set_default_version

            binding.pry
            set_title_for_default_version

            binding.pry
            @article.save!

            binding.pry
            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def technology
          @article
        end

        def entity
          @article
        end

        private

        def create_article
          binding.pry
          @article = ::Articles::Article.new(@params.except(:tag_list))
        end

        def set_visibility
          binding.pry
          @article.visibility_status = ::Articles::VisibilityStatusTypes[:public]
        end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @article.folder = @target_place
          elsif @target_place.class == Repository
            @article.repository = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            binding.pry
            container_member = create_container_member

            binding.pry
            @article.class_containers << container_member
          elsif @target_place.class == ::SimpleClasses::InterfaceGroup

            binding.pry
            interface_member = create_interface_member

            binding.pry
            @article.interface_members << interface_member
          end
        end

        def set_default_version
          binding.pry
          @article.default_version = first_article_version
        end

        def set_title_for_default_version
          article_version = first_article_version
          article_version.title = @article.title
        end

        def set_owner
          binding.pry
          @article.ownerable = @owner
        end

        def set_creator
          binding.pry
          @article.creator = @creator
        end

        def first_article_version
          @article.article_versions.first
        end

      end
    end
  end
end
