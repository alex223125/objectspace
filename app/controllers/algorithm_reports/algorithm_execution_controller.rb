class AlgorithmReports::AlgorithmExecutionController < ApplicationController
  include AlgorithmExecutionBreadcrumbable

  before_action :set_algorithm_report, only: %i[ initial_place ]
  before_action :set_algorithm_step, only: %i[ edit update included_algorithm_reports_options_pick ]

  def initial_place
    binding.pry
    @duplicate_algorithm_version = @algorithm_report.duplicate_algorithm_version
    @algorithm = @duplicate_algorithm_version.algorithm
    @introduction_step = @algorithm_report.logging_introduction_step
    technology_breadcrumbs(@introduction_step)
  end

  def show
  end

  # DOC: we use edit form to open logging step
  def edit
    binding.pry
    algorithm_report = @algorithm_step.algorithm_report
    if algorithm_report.completed?
      # DOC: If algorithm report was already completed then we redirect
      # on the page where we display results of completion of AlgorithmReport
      show_action_path = algorithm_report_path(ownername: algorithm_report.ownerable.ownername,
                                                 id: algorithm_report.slug)
      notice = "Report already completed."
      redirect_to show_action_path, notice: notice
    elsif algorithm_report.in_progress?
      technology_breadcrumbs(@algorithm_step)
    end
  end

  def update
    binding.pry
    # TODO: put inside of the servcie object
    @algorithm_step.assign_attributes(step_params)
    @algorithm_step.save!
    @algorithm_report = @algorithm_step.algorithm_report

    respond_to do |format|
      binding.pry
      if @algorithm_step.errors.blank? && @algorithm_report.errors.blank?

        if next_step_present?(@algorithm_step)
          # DOC: Case 1: after changes made in edit form we commit and redirect to next step if next step exsits
          next_step = @algorithm_step.next_node

          binding.pry
          if next_step.included_content_type_is_algorithm?
            # DOC: Case 1.1 If we have step which includes algorithm inside then we redirect on
            # page where we pick which version of algorithm we will execute
            binding.pry
            after_success_path = included_algorithm_reports_options_pick_path(next_step.uuid)
          else
            # DOC: Case 1.2 If we have regular step then we proceed with regular step
            after_success_path = algorithm_reports_algorithm_execution_path(next_step.uuid)
          end
          notice = "Step was successfully completed."
        elsif last_algorithm_execution_step?(@algorithm_step)
          # DOC: Case 2: after saving on last step we redirect user to "show" action of report
          binding.pry
          after_success_path = algorithm_report_path(ownername: @algorithm_report.ownerable.ownername,
                                                     id: @algorithm_report.slug)
          notice = "Algorithm was successfully completed."

          service = Services::AlgorithmReports::AlgorithmReports::ChangeToCompleted.new(@algorithm_report)
          service.call
        end


        binding.pry
        format.html { redirect_to after_success_path, notice: notice }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def included_algorithm_reports_options_pick
    binding.pry
    @included_algorithm_reports = @algorithm_step.algorithm_reports_based_on_included_algorithms
  end

  private

  def set_algorithm_report
    binding.pry
    @algorithm_report = AlgorithmReports::AlgorithmReport.find_by(uuid: params[:uuid])
  end

  def set_algorithm_step
    binding.pry
    @algorithm_step = AlgorithmReports::Nodes::LoggingNode.find_by(uuid: params[:logging_step_id])
  end

  def step_params
    binding.pry
    params.require(:algorithm_reports_nodes_logging_step).permit(:content)
  end

end

