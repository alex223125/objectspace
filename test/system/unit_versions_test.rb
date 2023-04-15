require "application_system_test_case"

class UnitVersionsTest < ApplicationSystemTestCase
  setup do
    @unit_version = unit_versions(:one)
  end

  test "visiting the index" do
    visit unit_versions_url
    assert_selector "h1", text: "Unit versions"
  end

  test "should create unit version" do
    visit unit_versions_url
    click_on "New unit version"

    fill_in "Additional information", with: @unit_version.additional_information
    fill_in "Instruction", with: @unit_version.instruction
    fill_in "Solves the problem", with: @unit_version.solves_the_problem
    fill_in "Sources", with: @unit_version.sources
    fill_in "Title", with: @unit_version.title
    click_on "Create Unit version"

    assert_text "Unit version was successfully created"
    click_on "Back"
  end

  test "should update Unit version" do
    visit unit_version_url(@unit_version)
    click_on "Edit this unit version", match: :first

    fill_in "Additional information", with: @unit_version.additional_information
    fill_in "Instruction", with: @unit_version.instruction
    fill_in "Solves the problem", with: @unit_version.solves_the_problem
    fill_in "Sources", with: @unit_version.sources
    fill_in "Title", with: @unit_version.title
    click_on "Update Unit version"

    assert_text "Unit version was successfully updated"
    click_on "Back"
  end

  test "should destroy Unit version" do
    visit unit_version_url(@unit_version)
    click_on "Destroy this unit version", match: :first

    assert_text "Unit version was successfully destroyed"
  end
end
