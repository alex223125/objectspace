require "application_system_test_case"

class CheatSheetVersionsTest < ApplicationSystemTestCase
  setup do
    @cheat_sheet_version = cheat_sheet_versions(:one)
  end

  test "visiting the index" do
    visit cheat_sheet_versions_url
    assert_selector "h1", text: "Cheat sheet versions"
  end

  test "should create cheat sheet version" do
    visit cheat_sheet_versions_url
    click_on "New cheat sheet version"

    fill_in "Description", with: @cheat_sheet_version.description
    fill_in "Title", with: @cheat_sheet_version.title
    click_on "Create Cheat sheet version"

    assert_text "Cheat sheet version was successfully created"
    click_on "Back"
  end

  test "should update Cheat sheet version" do
    visit cheat_sheet_version_url(@cheat_sheet_version)
    click_on "Edit this cheat sheet version", match: :first

    fill_in "Description", with: @cheat_sheet_version.description
    fill_in "Title", with: @cheat_sheet_version.title
    click_on "Update Cheat sheet version"

    assert_text "Cheat sheet version was successfully updated"
    click_on "Back"
  end

  test "should destroy Cheat sheet version" do
    visit cheat_sheet_version_url(@cheat_sheet_version)
    click_on "Destroy this cheat sheet version", match: :first

    assert_text "Cheat sheet version was successfully destroyed"
  end
end
