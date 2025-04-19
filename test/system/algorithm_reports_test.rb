require "application_system_test_case"

class AlgorithmReportsTest < ApplicationSystemTestCase
  setup do
    @algorithm_report = algorithm_reports(:one)
  end

  test "visiting the index" do
    visit algorithm_reports_url
    assert_selector "h1", text: "Algorithm reports"
  end

  test "should create algorithm report" do
    visit algorithm_reports_url
    click_on "New algorithm report"

    fill_in "Description", with: @algorithm_report.description
    fill_in "Title", with: @algorithm_report.title
    click_on "Create Algorithm report"

    assert_text "Algorithm report was successfully created"
    click_on "Back"
  end

  test "should update Algorithm report" do
    visit algorithm_report_url(@algorithm_report)
    click_on "Edit this algorithm report", match: :first

    fill_in "Description", with: @algorithm_report.description
    fill_in "Title", with: @algorithm_report.title
    click_on "Update Algorithm report"

    assert_text "Algorithm report was successfully updated"
    click_on "Back"
  end

  test "should destroy Algorithm report" do
    visit algorithm_report_url(@algorithm_report)
    click_on "Destroy this algorithm report", match: :first

    assert_text "Algorithm report was successfully destroyed"
  end
end
