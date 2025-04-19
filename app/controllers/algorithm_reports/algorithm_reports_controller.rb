class AlgorithmReports::AlgorithmReportsController < ApplicationController
  include TechBreadcrumbable

  before_action :set_algorithm_report, only: %i[ show edit update destroy ]

  # GET /algorithm_reports or /algorithm_reports.json
  def index
    @algorithm_reports = AlgorithmReport.all
  end

  # GET /algorithm_reports/1 or /algorithm_reports/1.json
  def show
    report_breadcrumbs(@algorithm_report)
    binding.pry
  end

  # GET /algorithm_reports/new
  def new
    binding.pry
    @algorithm_version = Algorithms::AlgorithmVersion.find_by(uuid: params[:algorithm_version_uuid])
    @algorithm_report = AlgorithmReports::AlgorithmReport.new
  end

  # GET /algorithm_reports/1/edit
  def edit
  end

  # POST /algorithm_reports or /algorithm_reports.json
  def create
    binding.pry
    @algorithm_version = Algorithms::AlgorithmVersion.find_by(uuid: params[:algorithm_version_uuid])

    binding.pry
    service = Services::AlgorithmReports::AlgorithmReports::Create.new(algorithm_report_params, @algorithm_version, current_user)
    service.call

    binding.pry
    respond_to do |format|
      if service.errors.blank?

        binding.pry
        format.html { redirect_to algorithm_reports_algorithm_execution_initial_place_path(uuid: service.algorithm_report.uuid),
                                  notice: "Algorithm report was successfully created." }
        format.json { render :show, status: :created, location: @algorithm_report }
      else
        format.html { render :new, status: :unprocessable_entity, assigns: { algorithm_report: service.algorithm_report} }
        format.json { render json: @algorithm_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /algorithm_reports/1 or /algorithm_reports/1.json
  def update
    respond_to do |format|
      if @algorithm_report.update(algorithm_report_params)
        format.html { redirect_to algorithm_report_url(@algorithm_report), notice: "Algorithm report was successfully updated." }
        format.json { render :show, status: :ok, location: @algorithm_report }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @algorithm_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /algorithm_reports/1 or /algorithm_reports/1.json
  def destroy
    @algorithm_report.destroy

    respond_to do |format|
      format.html { redirect_to algorithm_reports_url, notice: "Algorithm report was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_algorithm_report
      binding.pry
      @algorithm_report = AlgorithmReports::AlgorithmReport.find_by_uuid(params[:uuid]) || AlgorithmReports::AlgorithmReport.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def algorithm_report_params
      binding.pry
      params.require(:algorithm_reports_algorithm_report).permit(:title, :description, :tag_list)
    end
end
