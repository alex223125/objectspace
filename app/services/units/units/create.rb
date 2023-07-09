module Services
  module Units
    module Units
      class Create

        attr_reader :errors, :unit

        def initialize(params, target_folder, current_user)
          @params = params
          @target_folder = target_folder
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_unit

            binding.pry
            set_usage_unit_example_flag

            binding.pry
            set_owner
            set_folder
            set_tags

            binding.pry
            set_visibility

            binding.pry
            @unit.save!

            binding.pry
            set_default_version
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_unit
          binding.pry
          @unit = ::Units::Unit.new(@params.except(:tag_list))
        end

        def set_usage_unit_example_flag
          binding.pry
          @unit.unit_usage_examples.each do |example|
            example.is_for_all_unit_versions = true
          end
        end

        def set_visibility
          binding.pry
          @unit.visibility_status = ::Units::VisibilityStatusTypes[:public]
        end

        def set_default_version
          binding.pry
          @unit.default_version_id = @unit.unit_versions.first.id
          @unit.save!
        end

        def set_owner
          @unit.ownerable = @current_user
        end

        def set_folder
          @unit.folder = @target_folder
        end

        def set_tags
          binding.pry
          @unit.tag_list = parse_tags
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