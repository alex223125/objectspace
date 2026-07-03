# app/controllers/api/algorithm_improvements_controller.rb
module Api
  class ImprovementsController < ApplicationController
    # Enforce authentication layer logic before processing actions
    before_action :authenticate_user!

    # Protect from forgery utilizing a null session for stateless API structures
    protect_from_forgery with: :null_session

    before_action :set_algorithm_version

    # GET /api/algorithms/:algorithm_id/improvements
    def index
      @improvements = Improvements::Improvement.where(improvable_type: "Algorithms::AlgorithmVersion",
                                                      improvable_id: @algorithm_version.id)
                                               .order(created_at: :desc).limit(5)

      render json: @improvements.map { |imp| serialize_improvement(imp) }, status: :ok
    end

    def parse_tags
      if improvement_params[:tag_list].present?
        JSON.parse(improvement_params[:tag_list]).map{|h| h.values}.join(",")
      end
    end

    # POST /api/algorithms/:algorithm_id/improvements
    def create
      binding.pry
      @improvement = Improvements::Improvement.new(improvement_params)
      @improvement.improvable = @algorithm_version
      @improvement.ownerable = current_user
      @improvement.creator = current_user
      @improvement.active_status_type = Improvements::ActiveStatusTypes[:open]

      binding.pry
      @improvement.tags
      # @improvement.tag_list = parse_tags

      binding.pry
      if @improvement.save

        binding.pry
        render json: {
          success: true,
          improvement: serialize_improvement(@improvement),
          message: "Refinement deployed successfully. +50 XP acquired."
        }, status: :created
      else

        binding.pry
        render json: {
          success: false,
          errors: @improvement.errors.full_messages
        }, status: :unprocessable_entity
      end


    end

    private

    def set_algorithm_version
      # Natively match the explicit slug column layout to avoid friendly_id join failures
      binding.pry
      @algorithm_version = ::Algorithms::AlgorithmVersion.find_by(slug: params[:algorithm_version_id]) ||
        ::Algorithms::AlgorithmVersion.friendly.find(params[:algorithm_version_id])

      if @algorithm_version.nil?
        binding.pry
        render json: { success: false, error: "Target algorithm profile matrix not found." }, status: :not_found
      end
    end

    def improvement_params
      binding.pry
      # FIXED: Uses an operational fetch wrapper fallback to safely intercept both
      # :improvements_improvement (from Rails forms) and :improvement (from raw JSON API calls)

      binding.pry
      nested_data = params[:improvements_improvement] || params[:improvement]


      binding.pry
      if nested_data.blank?
        binding.pry
        render json: { success: false, error: "Missing required parameter payload." }, status: :bad_request
      else
        binding.pry
        nested_data.permit(:title, :content, :sources, :tag_list)
      end
    end

    # Serializer to strip active storage attachment metadata overhead
    def serialize_improvement(improvement)
      {
        id: improvement.id,
        title: improvement.title,
        content: improvement.content.to_s,
        sources: improvement.sources.to_s,

        # CORE FIX: Explicitly cast to a clean native array of string tokens
        tag_list: improvement.tag_list.to_a,

        created_at: ActionController::Base.helpers.time_ago_in_words(improvement.created_at) + " ago"
      }
    end
  end
end
