module Services
  module Algorithms
    module Algorithms
      class Create

        # MAX_ALLOWED_AMOUNT_OF_STEPS_PER_NEW_ALGORITHM_CREATION = 5.freeze

        attr_reader :errors, :algorithm, :dynamic_steps

        def initialize(params, target_folder, current_user)
          @params = params
          @target_folder = target_folder
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_algorithm

            binding.pry
            set_visibility

            binding.pry
            set_folder
            set_owner
            set_tags

            binding.pry
            @algorithm.save!

            binding.pry
            set_default_version
          end
        rescue ActiveRecord::RecordInvalid, StandardError => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_algorithm
          binding.pry
          @algorithm = ::Algorithms::Algorithm.new(@params.except(:tag_list))
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

        def set_folder
          binding.pry
          @algorithm.folder = @target_folder
        end

        def set_owner
          binding.pry
          @algorithm.ownerable = @current_user
        end

        def set_tags
          binding.pry
          @algorithm.tag_list = parse_tags
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