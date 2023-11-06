module Services
  module Articles
    module Articles
      class Create

        attr_reader :errors, :article

        def initialize(params, target_folder, current_user)
          @params = params
          @target_folder = target_folder
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_article

            binding.pry
            set_visibility

            binding.pry
            set_owner

            binding.pry
            set_folder
            set_tags

            binding.pry
            set_default_version

            binding.pry
            @article.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
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

        def set_folder
          binding.pry
          @article.folder = @target_folder
        end

        def set_default_version
          binding.pry
          @article.default_version = @article.article_versions.first
        end

        def set_owner
          binding.pry
          @article.ownerable = @current_user
        end

        def set_tags
          binding.pry
          @article.tag_list = parse_tags
        end

        def parse_tags
          if @params[:tag_list].present?
            JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
          end
        end

      end
    end
  end
end
