require "application_system_test_case"

class CheatSheetGroupVersionsTest < ApplicationSystemTestCase
  setup do
    @cheat_sheet_group_version = cheat_sheet_group_versions(:one)
  end

  test "visiting the index" do
    visit cheat_sheet_group_versions_url
    assert_selector "h1", text: "Cheat sheet group versions"
  end

  test "should create cheat sheet group version" do
    visit cheat_sheet_group_versions_url
    click_on "New cheat sheet group version"

    fill_in "Description", with: @cheat_sheet_group_version.description
    fill_in "Title", with: @cheat_sheet_group_version.title
    click_on "Create Cheat sheet group version"

    assert_text "Cheat sheet group version was successfully created"
    click_on "Back"
  end

  test "should update Cheat sheet group version" do
    visit cheat_sheet_group_version_url(@cheat_sheet_group_version)
    click_on "Edit this cheat sheet group version", match: :first

    fill_in "Description", with: @cheat_sheet_group_version.description
    fill_in "Title", with: @cheat_sheet_group_version.title
    click_on "Update Cheat sheet group version"

    assert_text "Cheat sheet group version was successfully updated"
    click_on "Back"
  end

  test "should destroy Cheat sheet group version" do
    visit cheat_sheet_group_version_url(@cheat_sheet_group_version)
    click_on "Destroy this cheat sheet group version", match: :first

    assert_text "Cheat sheet group version was successfully destroyed"
  end
end
