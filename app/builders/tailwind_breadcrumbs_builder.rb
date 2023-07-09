# NOT IN USE
class TailwindBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  # def render
  #   @context.content_tag(:nav, class: 'flex py-3 px-5 text-slate-700 bg-slate-50 rounded-lg border border-slate-200', aria: { label: 'Breadcrumb' }) do
  #     @context.content_tag(:ol, class: 'inline-flex items-center space-x-1 md:space-x-3') do
  #       @elements.collect do |element|
  #         render_element(element)
  #       end.join.html_safe
  #     end
  #   end
  # end
  #
  # private
  #
  # def render_element(element)
  #   binding.pry
  #   current = @context.current_page?(compute_path(element))
  #   aria = current ? { aria: { current: 'page' } } : {}
  #
  #   @context.content_tag(:li, aria) do
  #     @context.content_tag(:div, class: 'inline-flex items-center') do
  #       current_or_regular_view(element, current)
  #     end
  #   end
  # end
  #
  # def current_or_regular_view(element, current)
  #   if current
  #     result = selected_page_view(element)
  #     result
  #   else
  #     link_or_text = regular_link(element)
  #     divider = regular_divider
  #     result = link_or_text + divider
  #     result
  #   end
  # end
  #
  # def selected_page_view(element)
  #   # @context.content_tag(:span, compute_name(element), class: "ml-1 text-sm font-medium text-gray-500 md:ml-2 dark:text-gray-400").html_safe
  #   @context.content_tag(:span, compute_name(element), class: "inline-flex text-sm font-medium text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white").html_safe
  # end
  #
  # def regular_link(element)
  #   @context.link_to(compute_path(element),
  #                   element.options.merge(class: 'inline-flex text-sm font-medium text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white')) do
  #
  #     if @context.breadcrumbs.first.name == element.name
  #       home_icon + compute_name(element)
  #     else
  #       compute_name(element)
  #     end
  #   end
  # end
  #
  # def regular_divider
  #   @context.content_tag(:svg, "aria-hidden": "true", class: "w-6 h-6 text-gray-400", fill: "currentColor", "viewBox": "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do
  #     @context.content_tag(:path, nil, "fill-rule":"evenodd", d: "M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z", "clip-rule": "evenodd")
  #   end.html_safe
  # end
  #
  # def home_icon
  #   @context.content_tag(:svg, "aria-hidden": "true", class: "w-4 h-4 mr-2", fill: "currentColor", "viewBox": "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do
  #     @context.content_tag(:path, nil, d: "M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z")
  #   end.html_safe
  # end

end