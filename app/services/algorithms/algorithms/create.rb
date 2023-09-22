module Services
  module Algorithms
    module Algorithms
      class Create

        attr_reader :errors, :algorithm, :dynamic_steps

        def initialize(params, target_place, current_user, target_interface_group)
          @params = params
          @target_place = target_place
          @current_user = current_user
          @target_interface_group = target_interface_group
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
            set_tags

            binding.pry
            link_with_interface_group if @target_interface_group.present?

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

        def set_place
          binding.pry
          if @target_place.class == Folder
            @algorithm.folder = @target_place
          elsif @target_place.class == Repository
            @algorithm.repository = @target_place
          end
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

        def link_with_interface_group
          binding.pry
          interface_member = @target_interface_group.interface_members.new
          interface_member.memberable = @algorithm
          @algorithm.interface_members << interface_member
        end

      end
    end
  end
end