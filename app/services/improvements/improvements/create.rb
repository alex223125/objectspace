require "./app/services/concerns/shared/owner_permissionable"

module Services
  module Improvements
    module Improvements
      class Create
        include Services::Concerns::Shared::OwnerPermissionable

        attr_reader :errors, :improvement, :permissions

        def initialize(params, owner, creator)
          @params = params
          @owner = owner
          @creator = creator
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_improvement

            binding.pry
            set_owner
            set_creator

            binding.pry
            set_improvable
            set_active_status

            binding.pry
            @improvement.save!

            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def entity
          @improvement
        end

        private

        def create_improvement
          binding.pry
          except_keys = [:article_id, :unit_id, :algorithm_id]
          @improvement = ::Improvements::Improvement.new(@params.except(*except_keys))
        end

        def set_owner
          binding.pry
          @improvement.ownerable = @owner
        end

        def set_creator
          @improvement.creator = @creator
        end

        def set_improvable
          if @params[:article_id].present?
            article = ::Articles::Article.find_by(uuid: @params[:article_id])
            @improvement.improvable = article
          elsif @params[:unit_id].present?
            unit = ::Units::Unit.find_by(uuid: @params[:unit_id])
            @improvement.improvable = unit
          elsif @params[:algorithm_id].present?
            algorithm = ::Algorithms::Algorithm.find_by(uuid: @params[:algorithm_id])
            @improvement.improvable = algorithm
          end
        end

        def set_active_status
          @improvement.active_status_type = ::Improvements::ActiveStatusTypes[:open]
        end

      end
    end
  end
end