module Services
  module Articles
    module Articles
      class Create

        attr_reader :errors, :article

        def initialize(params, current_user)
          @params = params
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_article

            binding.pry
            set_visibility

            binding.pry
            put_in_root_folder

            binding.pry
            @article.save!

            binding.pry
            set_default_version
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_article
          binding.pry
          @article = ::Articles::Article.new(@params)
        end

        def set_visibility
          binding.pry
          @article.visibility_status = ::Articles::VisibilityStatusTypes[:public]
        end

        def set_default_version
          binding.pry
          @article.default_version_id = @article.article_versions.first.id
          @article.save!
        end

        def put_in_root_folder
          @article.folder = @current_user.root_folder
        end

      end
    end
  end
end