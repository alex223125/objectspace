require "application_system_test_case"

class CheatSheetGroupsTest < ApplicationSystemTestCase
  setup do
    @cheat_sheet_group = cheat_sheet_groups(:one)
  end

  test "visiting the index" do
    visit cheat_sheet_groups_url
    assert_selector "h1", text: "Cheat sheet groups"
  end

  test "should create cheat sheet group" do
    visit cheat_sheet_groups_url
    click_on "New cheat sheet group"

    fill_in "Description", with: @cheat_sheet_group.description
    fill_in "Title", with: @cheat_sheet_group.title
    click_on "Create Cheat sheet group"

    assert_text "Cheat sheet group was successfully created"
    click_on "Back"
  end

  test "should update Cheat sheet group" do
    visit cheat_sheet_group_url(@cheat_sheet_group)
    click_on "Edit this cheat sheet group", match: :first

    fill_in "Description", with: @cheat_sheet_group.description
    fill_in "Title", with: @cheat_sheet_group.title
    click_on "Update Cheat sheet group"

    assert_text "Cheat sheet group was successfully updated"
    click_on "Back"
  end

  test "should destroy Cheat sheet group" do
    visit cheat_sheet_group_url(@cheat_sheet_group)
    click_on "Destroy this cheat sheet group", match: :first

    assert_text "Cheat sheet group was successfully destroyed"
  end
end
