# MOVE TO API NAMESPACE as API controller
class SearchController < ApplicationController

  include Pagy::Backend

  ARTICLES_SEARCH_TYPE = 'articles'.freeze
  UNITS_SEARCH_TYPE = 'units'.freeze
  ALGORITHMS_SEARCH_TYPE = 'algorithms'.freeze
  CHEAT_SHEET_SEARCH_TYPE = 'cheat_sheets'.freeze
  CHEAT_SHEET_GROUP_SEARCH_TYPE = 'cheat_sheet_groups'.freeze
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

  # This method is used only for modal to pick technology during creation
  # rename to technology modal
  def index
    binding.pry
    # case 1. articles search
    if params[:query] && params[:type] == ARTICLES_SEARCH_TYPE
      binding.pry
      @articles = Articles::Article.search(params[:query], operator: "or",
                                           fields: [:title, :source_page_description],
                                           match: :text_middle)
      binding.pry
      @pagy, @articles = pagy(@articles, page: params[:page], items: 3)

      binding.pry
      if params[:scenario] == "step_attachment_addition"
        locals = {scenario: "step_attachment_addition"}
      elsif params[:scenario] == "unit_version_attachment_addition"
        locals = {scenario: "unit_version_attachment_addition"}
      elsif params[:scenario] == "article_version_attachment_addition"
        locals = {scenario: "article_version_attachment_addition"}
      elsif params[:scenario] == "regular"
        locals = {scenario: "regular"}
      elsif params[:scenario] == "cheat_sheet_version_notes_link_attachment_addition"
        locals = {scenario: "cheat_sheet_version_notes_link_attachment_addition"}
      else
        locals = {}
      end


      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/articles/list",
                                                   formats: [:html],
                                                   locals: locals),
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

      if params[:scenario] == "cheat_sheet_version_notes_link_attachment_addition"
        locals = {scenario: "cheat_sheet_version_notes_link_attachment_addition"}
      end

      binding.pry
      @pagy, @units = pagy(@units, page: params[:page], items: 3)
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/units/list",
                                                   formats: [:html],
                                                   locals: locals),
                         pagination: @pagy }
        }
      end

      # case 2. algorithms search
    elsif params[:query] && params[:type] == ALGORITHMS_SEARCH_TYPE
      binding.pry
      # @algorithms = Algorithms::Algorithm.english_global_search(params[:query])
      # @algorithms_versions = Algorithms::AlgorithmVersion.english_global_search(params[:query])
      @algorithms = Algorithms::Algorithm.search(params[:query], operator: "or",
                                                 fields:[{title: :text_middle}, {title: :word},
                                                         {title: :word_start}, {title: :word_end},
                                                         {source_page_description: :text_middle},
                                                         {source_page_description: :word},
                                                         {source_page_description: :word_start},
                                                         {source_page_description: :word_end}])
      binding.pry
      # @algorithms = Algorithms::Algorithm.search(params[:query], operator: "or",
      #                                            fields:[{name: :word_start}, ]
      # fields: [:title, :source_page_description],
      #   match: :word)
      # match: [:text_middle, :word, :word_start, :word_end]	)
      # @algorithms = @algorithms_groups + @algorithms_versions
      @pagy, @algorithms = pagy(@algorithms, page: params[:page], items: 3)

      if params[:scenario] == "cheat_sheet_version_notes_link_attachment_addition"
        locals = {scenario: "cheat_sheet_version_notes_link_attachment_addition"}
      end

      binding.pry
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/algorithms/list",
                                                   formats: [:html],
                                                   locals: locals),
                         pagination: @pagy }
        }
      end


      # case 3. cheat sheet
    elsif params[:query] && params[:type] == CHEAT_SHEET_SEARCH_TYPE
      @cheat_sheets = CheatSheets::CheatSheet.search(params[:query], operator: "or",
                                                    fields:[{title: :text_middle}, {title: :word},
                                                      {title: :word_start}, {title: :word_end},
                                                      {source_page_description: :text_middle},
                                                      {source_page_description: :word},
                                                      {source_page_description: :word_start},
                                                      {source_page_description: :word_end}]
      )

      @pagy, @cheat_sheets = pagy(@cheat_sheets, page: params[:page], items: 3)

      if params[:scenario] == "cheat_sheet_group_version_section_addition"
        locals = {scenario: "cheat_sheet_group_version_section_addition"}
      else
        locals = {}
      end

      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/cheat_sheets/list",
                                                  formats: [:html],
                                                  locals: locals),
                                                  pagination: @pagy }
        }
      end

      # case 4. cheat sheet group
    elsif params[:query] && params[:type] == CHEAT_SHEET_GROUP_SEARCH_TYPE
      @cheat_sheet_groups = CheatSheetGroups::CheatSheetGroup.search(params[:query], operator: "or",
                                                                    fields:[{title: :text_middle}, {title: :word},
                                                                      {title: :word_start}, {title: :word_end},
                                                                      {source_page_description: :text_middle},
                                                                      {source_page_description: :word},
                                                                      {source_page_description: :word_start},
                                                                      {source_page_description: :word_end}]
      )

      @pagy, @cheat_sheet_groups = pagy(@cheat_sheet_groups, page: params[:page], items: 3)

      if params[:scenario] == "cheat_sheet_group_version_section_addition"
        locals = {scenario: "cheat_sheet_group_version_section_addition"}
      else
        locals = {}
      end

      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/cheat_sheet_groups/list",
                                                  formats: [:html],
                                                  locals: locals),
                                                  pagination: @pagy }
        }
      end

      # case 5. classes search
    elsif params[:query] && params[:type] == CLASSES_SEARCH_TYPE
      binding.pry
      @simple_classes = SimpleClasses::SimpleClass.search(params[:query], operator: "or",
                                                          fields: [:title, :description], match: :text_middle)

      binding.pry
      @pagy, @simple_classes = pagy(@simple_classes, page: params[:page], items: 3)
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/simple_classes/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end

      # case 6. mixed technology search
    elsif params[:query] && params[:type] == FRAMEWORKS_SEARCH_TYPE
      binding.pry
      @frameworks = Frameworks::Framework.search(params[:query], operator: "or",
                                                 fields: [:title, :description], match: :text_middle)

      binding.pry
      @pagy, @frameworks = pagy(@frameworks, page: params[:page], items: 3)
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
                Algorithms::Algorithm, CheatSheets::CheatSheet, CheatSheetGroups::CheatSheetGroup,
                SimpleClasses::SimpleClass, Frameworks::Framework]
      fields = [:title, :description, :source_page_description]

      binding.pry
      @search_results = Searchkick.search(query, operator: "or", match: :text_middle,
                                          fields: fields, models: models)
      binding.pry
      ###
      @pagy, @search_results = pagy(@search_results, page: params[:page], items: 3)
      respond_to do |format|
        format.json {
          render json: { entries: render_to_string(partial: "shared/technologies_search/mixed_tech_select/list",
                                                   formats: [:html]),
                         pagination: @pagy }
        }
      end
    end
  end

  def user_dashboard_technologies
  end

  def folder_technologies
  end

  def technologies
    binding.pry
    # Case 1. Tecnologies for repository
    if params[:target_type] == "repository"
      target_type = "repository"
      target = Repository.friendly.find(params[:target])
      @folder_owner = target.ownerable

      # 1.1 child folders
      binding.pry
      @child_folders = target.folders

      # 1.2 methods whih in folder
      models = [Articles::Article, Units::Unit,
                Algorithms::Algorithm, CheatSheets::CheatSheet,
                SimpleClasses::SimpleClass, Frameworks::Framework]

      condition = {
        repository_id: target.id
      }

      find_all = '*'
      search_results = Searchkick.search(find_all, where: condition, models: models)
      @technologies = search_results

    # Case 2: technologies for folder
    elsif params[:target].present? && params[:target_type] == "folder"
      target_type = "folder"
      # if params[:target].present?
      #   # Case 1.Technologies based on folder we in
      #   target_folder = Folder.friendly.find(params[:target])
      #   @folder_owner = target_folder.user
      # elsif params[:target_user].present?
      #   # Case 2.Technologies for basic dashboard for user
      #   @folder_owner = User.where(username: params[:target_user]).first
      #   target_folder = @folder_owner.root_folder
      # end

      target_folder = Folder.friendly.find(params[:target])
      @folder_owner = target_folder.root.repository.ownerable

      # 1.1 child folders
      binding.pry
      @child_folders = target_folder.subfolders

      # 1.2 methods whih in folder
      models = [Articles::Article, Units::Unit,
                Algorithms::Algorithm, CheatSheets::CheatSheet, CheatSheetGroups::CheatSheetGroup,
                SimpleClasses::SimpleClass, Frameworks::Framework]

      condition = {
        folder_id: target_folder.id
      }

      find_all = '*'
      search_results = Searchkick.search(find_all, where: condition, models: models)
      @technologies = search_results
    elsif params[:tag].present?
      target_type = "search_by_tag"
      binding.pry
      @technologies = []
      @technologies += Articles::Article.tagged_with([params[:tag]], wild: true, any: true)
      @technologies += Units::Unit.tagged_with([params[:tag]], wild: true, any: true)
      @technologies += Algorithms::Algorithm.tagged_with([params[:tag]], wild: true, any: true)
      @technologies += CheatSheets::CheatSheet.tagged_with([params[:tag]], wild: true, any: true)
      @technologies += CheatSheetGroups::CheatSheetGroup.tagged_with([params[:tag]], wild: true, any: true)
      @technologies += SimpleClasses::SimpleClass.tagged_with([params[:tag]], wild: true, any: true)
      @technologies += Frameworks::Framework.tagged_with([params[:tag]], wild: true, any: true)

      # models = [Articles::Article, Units::Unit,
      #           Algorithms::Algorithm, SimpleClasses::SimpleClass,
      #           Frameworks::Framework]
      # condition = {
      #   list_of_tags: ["aaa", "bbb", "ccc"]
      # }
      #
      # condition = {
      #   list_of_tags: "aaa"
      # }
      #
      # condition = {
      #   list_of_tags: ["aaa", "ooo"]
      # }
      #
      # condition = ["list_of_tags LIKE aaa"]
      #
      # condition = {
      #   list_of_tags: "kkk"
      # }
      #
      # condition = {
      #   list_of_tags: ["kkk", "mmm"]
      # }
      #
      # find_all = '*'
      # search_results = Searchkick.search(find_all, where: condition, models: models)
      #
      # User.search("admi", fields: [{name: :text_middle}])
      # Articles::Article.search(find_all, where: condition)

    end

    respond_to do |format|
      format.json {
        render json: { entries: render_to_string(partial: "technologies/list",
                                                 formats: [:html],
                                                 locals: {list_type: "all_mixed_entries",
                                                          target_type: target_type }) }
        # current_folder_id: target_folder.id }
      }
    end
  end





  def serp_page_technologies
    # TODO: Move it to service object

    # Define scope of search
    binding.pry
    if params[:search_type] =="mixed-search"
      models = [Articles::Article, Units::Unit,
                Algorithms::Algorithm, SimpleClasses::SimpleClass,
                Frameworks::Framework]
    elsif params[:search_type] =="articles-search"
      models = [Articles::Article]
    elsif params[:search_type] =="methods-search"
      models = [Units::Unit]
    elsif params[:search_type] =="algorithms-search"
      models = [Algorithms::Algorithm]
    elsif params[:search_type] =="classes-search"
      models = [SimpleClasses::SimpleClass]
    elsif params[:search_type] =="frameworks-search"
      models = [Frameworks::Framework]
    end

    binding.pry
    # default
    find_all = '*'
    query = find_all
    conditions = {}

    binding.pry
    # building conditions
    if params[:tags].present?
      tags = params[:tags].split(",")
      conditions.merge!({ list_of_tags: tags })
    end

    binding.pry
    if params[:users].present?
      users_ids = params[:users].split(",")
      conditions.merge!({ ownerable_id: users_ids })
    end

    if params[:search_query].present?
      if params[:search_query] == "no-query"
        query = find_all
      else
        query = params[:search_query]
      end
    end

    binding.pry
    # Run search
    # search_results = Searchkick.search(query, where: condition, models: models)

    if params[:search_type] =="mixed-search"
      # format data from search results

      binding.pry
      @technologies_query = Searchkick.pagy_search(query, where: conditions, models: models)
      @technologies_pagy, @technologies = pagy_searchkick(@technologies_query, page: params[:page], items: 3)
      @technologies_count = @technologies_pagy.count

      @articles_query = Searchkick.pagy_search(query, where: conditions, models: Articles::Article)
      @articles_pagy, @articles = pagy_searchkick(@articles_query, page: params[:page], items: 3)
      @articles_count = @articles_pagy.count

      @units_query = Searchkick.pagy_search(query, where: conditions, models: Units::Unit)
      @units_pagy, @units = pagy_searchkick(@units_query, page: params[:page], items: 3)
      @units_count = @units_pagy.count

      @algorithms_query = Searchkick.pagy_search(query, where: conditions, models: Algorithms::Algorithm)
      @algorithms_pagy, @algorithms = pagy_searchkick(@algorithms_query, page: params[:page], items: 3)
      @algorithms_count = @algorithms_pagy.count

      @simple_classes_query = Searchkick.pagy_search(query, where: conditions, models: SimpleClasses::SimpleClass)
      @simple_classes_pagy, @simple_classes = pagy_searchkick(@simple_classes_query, page: params[:page], items: 3)
      @simple_classes_count = @simple_classes_pagy.count

      @frameworks_query = Searchkick.pagy_search(query, where: conditions, models: Frameworks::Framework)
      @frameworks_pagy, @frameworks = pagy_searchkick(@frameworks_query, page: params[:page], items: 3)
      @frameworks_count = @frameworks_pagy.count

      entries_amount = {technologies_count: @technologies_count,
                        articles_count: @articles_count,
                        units_count: @units_count,
                        algorithms_count: @algorithms_count,
                        simple_classes_count: @simple_classes_count,
                        frameworks_count: @frameworks_count }


    elsif params[:search_type] =="articles-search"
      binding.pry
      @articles_query = Searchkick.pagy_search(query, where: conditions, models: Articles::Article)
      @articles_pagy, @articles = pagy_searchkick(@articles_query, page: params[:page], items: 3)
      @articles_count = @articles_pagy.count

      entries_amount = { articles_count: @articles_count}
    elsif params[:search_type] =="methods-search"
      binding.pry
      @units_query = Searchkick.pagy_search(query, where: conditions, models: Units::Unit)
      @units_pagy, @units = pagy_searchkick(@units_query, page: params[:page], items: 3)
      @units_count = @units_pagy.count

      entries_amount = {units_count: @units_count}
    elsif params[:search_type] =="algorithms-search"
      binding.pry
      @algorithms_query = Searchkick.pagy_search(query, where: conditions, models: Algorithms::Algorithm)
      @algorithms_pagy, @algorithms = pagy_searchkick(@algorithms_query, page: params[:page], items: 3)
      @algorithms_count = @algorithms_pagy.count

      entries_amount = {algorithms_count: @algorithms_count }
    elsif params[:search_type] =="classes-search"
      binding.pry
      @simple_classes_query = Searchkick.pagy_search(query, where: conditions, models: SimpleClasses::SimpleClass)
      @simple_classes_pagy, @simple_classes = pagy_searchkick(@simple_classes_query, page: params[:page], items: 3)
      @simple_classes_count = @simple_classes_pagy.count

      entries_amount = {simple_classes_count: @simple_classes_count }
    elsif params[:search_type] =="frameworks-search"
      binding.pry
      @frameworks_query = Searchkick.pagy_search(query, where: conditions, models: Frameworks::Framework)
      @frameworks_pagy, @frameworks = pagy_searchkick(@frameworks_query, page: params[:page], items: 3)
      @frameworks_count = @frameworks_pagy.count

      entries_amount = {frameworks_count: @frameworks_count}
    end

    # generating response
    if params[:search_type] =="mixed-search"
      binding.pry
      response = { all_mixed_entries: render_to_string(partial: "technologies/list",
                                                       formats: [:html], :locals => {:list_type => "all_mixed_entries"}),
                   technologies_pagination: @technologies_pagy,

                   articles_entries: render_to_string(partial: "technologies/list",
                                                      formats: [:html], :locals => {:list_type => "articles_entries"}),
                   articles_pagination: @articles_pagy,

                   units_entries: render_to_string(partial: "technologies/list",
                                                   formats: [:html], :locals => {:list_type => "units_entries"}),
                   units_pagination: @units_pagy,

                   algorithms_entries: render_to_string(partial: "technologies/list",
                                                        formats: [:html], :locals => {:list_type => "algorithms_entries"}),
                   algorithms_pagination: @algorithms_pagy,

                   simple_classes_entries: render_to_string(partial: "technologies/list",
                                                            formats: [:html], :locals => {:list_type => "simple_classes_entries"}),
                   simple_classes_pagination: @simple_classes_pagy,

                   frameworks_entries: render_to_string(partial: "technologies/list",
                                                        formats: [:html], :locals => {:list_type => "frameworks_entries"}),
                   frameworks_pagination: @frameworks_pagy,

                   entries_amount: entries_amount}
    elsif params[:search_type] =="articles-search"
      binding.pry
      response = { articles_entries: render_to_string(partial: "technologies/list",
                                                      formats: [:html], :locals => {:list_type => "articles_entries"}),
                   articles_pagination: @articles_pagy,
                   entries_amount: entries_amount}
    elsif params[:search_type] =="methods-search"
      binding.pry
      response = { units_entries: render_to_string(partial: "technologies/list",
                                                   formats: [:html], :locals => {:list_type => "units_entries"}),
                   units_pagination: @units_pagy,
                   entries_amount: entries_amount}
    elsif params[:search_type] =="algorithms-search"
      binding.pry
      response = { algorithms_entries: render_to_string(partial: "technologies/list",
                                                        formats: [:html], :locals => {:list_type => "algorithms_entries"}),
                   algorithms_pagination: @algorithms_pagy,
                   entries_amount: entries_amount}
    elsif params[:search_type] =="classes-search"
      binding.pry
      response = { simple_classes_entries: render_to_string(partial: "technologies/list",
                                                            formats: [:html], :locals => {:list_type => "simple_classes_entries"}),
                   simple_classes_pagination: @simple_classes_pagy,
                   entries_amount: entries_amount}

    elsif params[:search_type] =="frameworks-search"
      binding.pry
      response = { frameworks_entries: render_to_string(partial: "technologies/list",
                                                        formats: [:html], :locals => {:list_type => "frameworks_entries"}),
                   frameworks_pagination: @frameworks_pagy,
                   entries_amount: entries_amount}

    end

    binding.pry
    ## prepare json response

    binding.pry
    respond_to do |format|
      format.json {
        render json: response
      }
    end
  end

end
