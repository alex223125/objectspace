# app/controllers/api/algorithm_improvements_controller.rb
module Api
  class ImprovementsController < ApplicationController
    # Enforce authentication layer logic before processing actions
    before_action :authenticate_user!

    # Protect from forgery utilizing a null session for stateless API structures
    protect_from_forgery with: :null_session

    before_action :set_algorithm_version

    # GET /api/algorithms/:algorithm_id/entity_view_index
    def entity_view_index
      @improvements = Improvements::Improvement.where(improvable_type: "Algorithms::AlgorithmVersion",
                                                      improvable_id: @algorithm_version.id)
                                               .order(created_at: :desc).limit(5)

      render json: @improvements.map { |imp| serialize_improvement(imp) }, status: :ok
    end


    # GET /api/algorithms/:algorithm_id/improvements
    def index
      binding.pry
      # Unpack nested query parameters sent from improvements_infinite_scroll_controller.js
      search_data = params[:improvements_search] || {}


      binding.pry
      page_number = (search_data[:page] || params[:page] || 1).to_i
      per_page = 5
      offset_value = (page_number - 1) * per_page


      binding.pry
      # Build our database query scope context
      @improvements = Improvements::Improvement.where(
        improvable_type: "Algorithms::AlgorithmVersion",
        improvable_id: @algorithm_version.id
      )

      binding.pry
      # 1. Filter by open/closed status toggles
      if search_data[:status].present? && search_data[:status] != "view_all"
        status_type = search_data[:status] == "open_only" ? 1 : 0
        @improvements = @improvements.where(active_status_type: status_type)
      end

      binding.pry
      # # 2. Filter by search input keyword queries
      # if search_data[:query].present? && search_data[:query] != "FIRST_AUTOMATIC_SEARCH"
      #   query_string = "%#{search_data[:query].to_s.downcase}%"
      #   @improvements = @improvements.where("LOWER(title) LIKE ? OR LOWER(content) LIKE ?", query_string, query_string)
      # end

      # Locate this query check rule block inside your controller index method:
      # FIX: Only run database matching filters if an actual character string is provided
      if search_data[:query].present?
        query_string = "%#{search_data[:query].to_s.downcase}%"
        @improvements = @improvements.where("LOWER(title) LIKE ? OR LOWER(content) LIKE ?", query_string, query_string)
      end

      binding.pry
      # 3. Compute total page calculations to establish pagination boundaries
      total_records = @improvements.count
      total_pages = (total_records.to_f / per_page).ceil
      total_pages = 1 if total_pages.zero?

      binding.pry
      # Apply sorting, offset frames, and fetch records
      @improvements = @improvements.order(created_at: :desc).limit(per_page).offset(offset_value)

      respond_to do |format|
        # Safe fallback standard JSON response API block
        format.json do
          binding.pry
          # Core Strategy: Render the layout template rows into a raw string buffer block
          rendered_entries_html = render_to_string(
            partial: "algorithm/algorithm_versions/partials/improvements_content/improvement_card",
            collection: @improvements,
            as: :item,
            formats: [:html]
          )

          binding.pry
          render json: {
            entries: rendered_entries_html,
            pagination: {
              current: page_number,
              pages: total_pages
            }
          }, status: :ok
        end
      end
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

    # def set_algorithm_version
    #   # Natively match the explicit slug column layout to avoid friendly_id join failures
    #   binding.pry
    #   @algorithm_version = ::Algorithms::AlgorithmVersion.find_by(slug: params[:algorithm_version_id]) ||
    #     ::Algorithms::AlgorithmVersion.friendly.find(params[:algorithm_version_id])
    #
    #   if @algorithm_version.nil?
    #     binding.pry
    #     render json: { success: false, error: "Target algorithm profile matrix not found." }, status: :not_found
    #   end
    # end

    def set_algorithm_version
      # Read from root params or fall back to the nested search structure
      version_id = params[:algorithm_version_id] ||
        params.dig(:improvements_search, :tech_id)

      if version_id.blank?
        return render json: { success: false, error: "Algorithm Version ID is missing." }, status: :bad_request
      end

      # Natively match the explicit slug column layout to avoid friendly_id join failures
      @algorithm_version = ::Algorithms::AlgorithmVersion.find_by(slug: version_id) ||
        ::Algorithms::AlgorithmVersion.friendly.find(version_id)

      if @algorithm_version.nil?
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
