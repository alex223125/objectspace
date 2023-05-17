class SearchController < ApplicationController

  ARTICLES_SEARCH_TYPE = 'articles'.freeze
  UNITS_SEARCH_TYPE = 'units'.freeze
  ALGORITHMS_SEARCH_TYPE = 'algorithms'.freeze
  CLASSES_SEARCH_TYPE = 'simple_class'.freeze
  FRAMEWORKS_SEARCH_TYPE = 'frameworks'.freeze
  ALL_TECHNOLOGIES_SEARCH_TYPE = 'all_technologies'.freeze

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
    # case 1. articles search
    if params[:query] && params[:type] == ARTICLES_SEARCH_TYPE
      binding.pry
      @articles = Articles::Article.search(params[:query], operator: "or",
                                           fields: [:title, :source_page_description],
                                           match: :text_middle)
      binding.pry
      @pagy, @articles = pagy(@articles, page: params[:page], items: 3 )
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/articles/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end

    # case 2. units search
    elsif params[:query] && params[:type] == UNITS_SEARCH_TYPE
      binding.pry
      # @unit_versions = Units::UnitVersion.english_global_search(params[:query])
      # @units = Units::Unit.english_unit_search(params[:query])
      @units = Units::Unit.search(params[:query], operator: "or",
                                  fields: [:title, :source_page_description], match: :text_middle)

      binding.pry
      @pagy, @units = pagy(@units, page: params[:page], items: 3 )
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/units/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end

    # case 2. algorithms search
    elsif params[:query] && params[:type] == ALGORITHMS_SEARCH_TYPE
      binding.pry
      # @algorithms = Algorithms::Algorithm.english_global_search(params[:query])
      # @algorithms_versions = Algorithms::AlgorithmVersion.english_global_search(params[:query])
      @algorithms = Algorithms::Algorithm.search(params[:query], operator: "or",
                                            fields: [:title, :source_page_description], match: :text_middle)

      binding.pry
      # @algorithms = @algorithms_groups + @algorithms_versions
      @pagy, @algorithms = pagy(@algorithms, page: params[:page], items: 3 )

      binding.pry
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/algorithms/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end

    # case 3. classes search
    elsif params[:query] && params[:type] == CLASSES_SEARCH_TYPE
      binding.pry
      @simple_classes = SimpleClasses::SimpleClass.search(params[:query], operator: "or",
                                                          fields: [:title, :description], match: :text_middle)

      binding.pry
      @pagy, @simple_classes = pagy(@simple_classes, page: params[:page], items: 3 )
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/simple_classes/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end

    # case 4. mixed technology search
    elsif params[:query] && params[:type] == FRAMEWORKS_SEARCH_TYPE
      binding.pry
      @frameworks = Frameworks::Framework.search(params[:query], operator: "or",
                                                 fields: [:title, :description], match: :text_middle)

      binding.pry
      @pagy, @frameworks = pagy(@frameworks, page: params[:page], items: 3 )
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/frameworks/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end
    elsif params[:query] && params[:type] == ALL_TECHNOLOGIES_SEARCH_TYPE
      binding.pry
      query = params[:query]
      models = [Articles::Article, Units::Unit,
                Algorithms::Algorithm, SimpleClasses::SimpleClass,
                Frameworks::Framework]
      fields = [:title, :description, :source_page_description]

      binding.pry
      @search_results = Searchkick.search(query, operator: "or", match: :text_middle,
                                          fields: fields, models: models)
      binding.pry
      ###
      @pagy, @search_results = pagy(@search_results, page: params[:page], items: 3 )
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/mixed_tech_select/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end
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