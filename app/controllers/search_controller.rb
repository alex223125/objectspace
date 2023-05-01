class SearchController < ApplicationController

  UNITS_SEARCH_TYPE = 'units'.freeze
  ALGORITHMS_SEARCH_TYPE = 'algorithms'.freeze

  def instructions_autocomplete

    # get params
    # search in units and algorithms
    # return 10 results

    # term = params[:term]
    #
    # @project = search_service.project
    # @ref = params[:project_ref] if params[:project_ref].present?
    # @filter = params[:filter]
    #
    # # Cache the response on the frontend
    # expires_in 1.minute
    #
    # render json: Gitlab::Json.dump(search_autocomplete_opts(term, filter: @filter))
  end

  def index
    binding.pry
    # case 1. units search
    if params[:query] && params[:type] == UNITS_SEARCH_TYPE
      binding.pry
      @unit_versions = Units::UnitVersion.english_global_search(params[:query])
      @pagy, @unit_versions = pagy(@unit_versions, page: params[:page], items: 3 )
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "algorithm/shared/partials/instructions_search/units/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end
    # case 2. algorithms search
    elsif params[:query] && params[:type] == ALGORITHMS_SEARCH_TYPE
      binding.pry
      # @algorithms_groups = Algorithms::Algorithm.english_global_search(params[:query])
      @algorithms_versions = Algorithms::AlgorithmVersion.english_global_search(params[:query])

      binding.pry
      # @algorithms = @algorithms_groups + @algorithms_versions

      @pagy, @algorithms_versions = pagy(@algorithms_versions, page: params[:page], items: 3 )

      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "algorithm/shared/partials/instructions_search/algorithms/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end
    else
      @units = Units::Unit.all
    end




    # format.html

    # format.json do
    #
    #   binding.pry
    #   form_stub = Algorithms::Step.new
    #
    #   # binding.pry
    #   # form_builder = view_context.form_for(form_stub) { |builder| break builder }
    #
    #   form_builder = ActionView::Helpers::FormBuilder.new(
    #     'object', # the scope for the inputs
    #     form_stub,        # object wrapped by the form builder
    #     view_context,  # the template where the form builder can call the tag helpers on
    #     {}             # options
    #   )
    #
    #   html = render_to_string(
    #     entries: render_to_string(partial: "algorithm/shared/partials/instructions_autocomplete/units/list",
    #     formats: [:html],
    #     locals: { form: form_builder })
    #   )
    #   # render json: { html: html }
    #   binding.pry
    #   render json: html
    # end



  end


  # def index
  #   respond_to do |format|
  #
  #     format.json do
  #       form_builder = view_context.form_for(@some_object) { |builder| break builder }
  #
  #       html = render_to_string(
  #         '/path/to/_form.html.erb',
  #         layout: false,
  #         locals: { f: form_builder }
  #       )
  #       render json: { html: html }
  #     end
  #   end
  # end


  # def index
  #
  #   @results
  #
  #   @results = search_for_posts
  #
  #   binding.pry
  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream:
  #                # turbo_stream.update('posts',
  #                #                     partial: 'posts/posts',
  #                #                     locals: { posts: @results })
  #                turbo_stream.update('units',
  #                                    partial: 'algorithm/shared/partials/instructions_autocomplete/units/list',
  #                                    locals: { units: @results })
  #
  #       # render turbo_stream:
  #       #          # turbo_stream.update('posts',
  #       #          #                     partial: 'posts/posts',
  #       #          #                     locals: { posts: @results })
  #       #          turbo_stream.update('units',
  #       #                              partial: 'algorithm/shared/partials/instructions_autocomplete/units/list',
  #       #                              locals: { units: @results }), content_type: "text/html"
  #
  #       # render turbo_stream: turbo_stream.replace("units",
  #       #                               partial: "algorithm/shared/partials/instructions_autocomplete/units/list",
  #       #                               locals: {units: @results})
  #
  #     end
  #     # format.html do
  #     #   render turbo_stream:
  #     #            # turbo_stream.update('posts',
  #     #            #                     partial: 'posts/posts',
  #     #            #                     locals: { posts: @results })
  #     #            turbo_stream.update('unitsss',
  #     #                                partial: 'algorithm/shared/partials/instructions_autocomplete/units/list',
  #     #                                locals: { units: @results })
  #     # end
  #     # format.html {}
  #   end
  #
  # end

  def suggestions
    @results = search_for_posts

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream:
                 turbo_stream.update('suggestions',
                                     # partial: 'search/suggestions',
                                     partial: 'algorithm/shared/partials/instructions_autocomplete/units/suggestions',
                                     locals: { results: @results })
      end
    end
  end

  private

  def search_for_posts
    if params[:query].blank?
      Units::Unit.all
    else
      Units::Unit.search(params[:query], fields: %i[title source_page_description], operator: 'or', match: :text_middle)
    end
  end
end