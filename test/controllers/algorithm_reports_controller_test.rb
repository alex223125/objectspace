require "test_helper"

class AlgorithmReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @algorithm_report = algorithm_reports(:one)
  end

  test "should get index" do
    get algorithm_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_algorithm_report_url
    assert_response :success
  end

  test "should create algorithm_report" do
    assert_difference("AlgorithmReport.count") do
      post algorithm_reports_url, params: { algorithm_report: { description: @algorithm_report.description, title: @algorithm_report.title } }
    end

    assert_redirected_to algorithm_report_url(AlgorithmReport.last)
  end

  test "should show algorithm_report" do
    get algorithm_report_url(@algorithm_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_algorithm_report_url(@algorithm_report)
    assert_response :success
  end

  test "should update algorithm_report" do
    patch algorithm_report_url(@algorithm_report), params: { algorithm_report: { description: @algorithm_report.description, title: @algorithm_report.title } }
    assert_redirected_to algorithm_report_url(@algorithm_report)
  end

  test "should destroy algorithm_report" do
    assert_difference("AlgorithmReport.count", -1) do
      delete algorithm_report_url(@algorithm_report)
    end

    assert_redirected_to algorithm_reports_url
  end
end
