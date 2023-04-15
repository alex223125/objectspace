require "application_system_test_case"

class AlgorithmVersionsTest < ApplicationSystemTestCase
  setup do
    @algorithm_version = algorithm_versions(:one)
  end

  test "visiting the index" do
    visit algorithm_versions_url
    assert_selector "h1", text: "Algorithm versions"
  end

  test "should create algorithm version" do
    visit algorithm_versions_url
    click_on "New algorithm version"

    fill_in "Additional information", with: @algorithm_version.additional_information
    fill_in "Solves the problem", with: @algorithm_version.solves_the_problem
    fill_in "Sources", with: @algorithm_version.sources
    fill_in "Title", with: @algorithm_version.title
    click_on "Create Algorithm version"

    assert_text "Algorithm version was successfully created"
    click_on "Back"
  end

  test "should update Algorithm version" do
    visit algorithm_version_url(@algorithm_version)
    click_on "Edit this algorithm version", match: :first

    fill_in "Additional information", with: @algorithm_version.additional_information
    fill_in "Solves the problem", with: @algorithm_version.solves_the_problem
    fill_in "Sources", with: @algorithm_version.sources
    fill_in "Title", with: @algorithm_version.title
    click_on "Update Algorithm version"

    assert_text "Algorithm version was successfully updated"
    click_on "Back"
  end

  test "should destroy Algorithm version" do
    visit algorithm_version_url(@algorithm_version)
    click_on "Destroy this algorithm version", match: :first

    assert_text "Algorithm version was successfully destroyed"
  end
end
