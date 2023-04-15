module Services
  module Articles
    module Articles
      class Create

        attr_reader :errors, :article

        def initialize(params)
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_article

            binding.pry
            set_visibility

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

      end
    end
  end
end