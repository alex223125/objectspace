module AlgorithmExecutionBreadcrumbable
  extend ActiveSupport::Concern

  def technology_breadcrumbs(technology)
    binding.pry
    if technology.class == AlgorithmReports::LoggingIntroductionStep
      # 1 title of report
      add_breadcrumb technology.algorithm_report.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
      # steps
      add_breadcrumb "Steps", technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
      # introduction
      add_breadcrumb "Introduction", technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
    elsif technology.class == AlgorithmReports::Nodes::LoggingStep
      binding.pry
      # 1 title of report
      add_breadcrumb technology.algorithm_report.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
      # steps
      add_breadcrumb "Steps", technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
      # Logging step
      add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
    end
  end

  private

  def technology_path(technology)
    binding.pry
    if technology.class == AlgorithmReports::LoggingIntroductionStep
      {path: algorithm_reports_algorithm_execution_initial_place_path(uuid: technology.algorithm_report.uuid),
       link_type: "algorithm_report_introduction_step"}
    elsif technology.class == AlgorithmReports::Nodes::LoggingStep
      {path: algorithm_reports_algorithm_execution_path(technology.uuid),
       link_type: "algorithm_report_introduction_step"}
    end
  end

end
