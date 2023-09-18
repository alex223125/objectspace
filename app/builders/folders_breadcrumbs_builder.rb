class FoldersBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Context

  PROFILE_PAGE_BREADCRUMB_TYPE = "profile_page".freeze
  FOLDER_PAGE_BREADCRUMB_TYPE = "folder_page".freeze
  REPOSITORY_PAGE_BREADCRUMB_TYPE = "repository_page".freeze
  # ARTICLE_VERSION_PAGE_BREADCRUMB_TYPE = "article_version_page".freeze
  # UNIT_VERSION_PAGE_BREADCRUMB_TYPE = "unit_version_page".freeze
  # ALGORITHM_VERSION_PAGE_BREADCRUMB_TYPE = "algorithm_version_page".freeze
  # SIMPLE_CLASS_PAGE_BREADCRUMB_TYPE = "class_page".freeze
  # FRAMEWORK_PAGE_BREADCRUMB_TYPE = "framework_page".freeze

  SELECTED_PAGE_STYLE = "hover:underline inline-flex text font-medium text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white font-bold".freeze
  REGULAR_PAGE_STYLE = "hover:underline inline-flex text font-medium text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white".freeze


  def render
    @context.content_tag(:nav, class: 'flex py-3 px-5 text-slate-700 bg-slate-50 rounded-lg border border-slate-200', aria: { label: 'Breadcrumb' }) do
      @context.content_tag(:ol, class: 'inline-flex flex-wrap items-center space-x-1 md:space-x-3') do
        @elements.collect do |element|
          render_element(element)
        end.join.html_safe
      end
    end
  end

  private

  def render_element(element)
    current = @context.current_page?(compute_path(element))
    aria = current ? { aria: { current: 'page' } } : {}

    @context.content_tag(:li, aria) do
      @context.content_tag(:div, class: 'inline-flex items-center') do
        current_or_regular_view(element, current)
      end
    end
  end

  def current_or_regular_view(element, current)
    if current
      result = custom_page_view(element, is_current: true)
      result
    else
      link_or_text = custom_page_view(element)
      divider = regular_divider
      result = link_or_text + divider
      result
    end
  end

  def custom_page_view(element, is_current: false)
    style = is_current ? SELECTED_PAGE_STYLE : REGULAR_PAGE_STYLE
    if element.options[:link_type] == PROFILE_PAGE_BREADCRUMB_TYPE
      profile_page_breadcrumb(element, style)
    elsif element.options[:link_type] == FOLDER_PAGE_BREADCRUMB_TYPE
      folder_page_breadcrumb(element, style)
    elsif element.options[:link_type] == REPOSITORY_PAGE_BREADCRUMB_TYPE
      repository_page_breadcrumb(element, style)
    else
      technology_page_breadcrumb(element, style)
    end
  end

  ###############
  def technology_page_breadcrumb(element, style)
    link_to element.path do
      @context.content_tag(:span, compute_full_name(element), class: style).html_safe
    end
  end

  def folder_page_breadcrumb(element, style)
    link_to element.path do
      @context.content_tag(:span, compute_full_name(element), class: style).html_safe
    end
  end

  def repository_page_breadcrumb(element, style)
    link_to element.path do
      @context.content_tag(:span, compute_full_name(element), class: style).html_safe
    end
  end

  def profile_page_breadcrumb(element, style)
    link_to dashboard_path(username: element.name) do
      @context.content_tag(:span, compute_full_name(element), class: style).html_safe
    end
  end
  ###############

  # add technology breadcrumb

  def compute_full_name(element)
    if @context.breadcrumbs.first.name == element.name
      home_icon + compute_name(element)
    else
      compute_name(element)
    end
  end

  ### icons
  def regular_divider
    @context.content_tag(:svg, "aria-hidden": "true", class: "w-6 h-6 text-gray-400", fill: "currentColor", "viewBox": "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do
      @context.content_tag(:path, nil, "fill-rule":"evenodd", d: "M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z", "clip-rule": "evenodd")
    end.html_safe
  end

  def home_icon
    @context.content_tag(:svg, "aria-hidden": "true", class: "w-4 h-4 mr-2", fill: "currentColor", "viewBox": "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do
      @context.content_tag(:path, nil, d: "M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z")
    end.html_safe
  end

end