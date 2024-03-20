require "application_system_test_case"

class CheatSheetsTest < ApplicationSystemTestCase
  setup do
    @cheat_sheet = cheat_sheets(:one)
  end

  test "visiting the index" do
    visit cheat_sheets_url
    assert_selector "h1", text: "Cheat sheets"
  end

  test "should create cheat sheet" do
    visit cheat_sheets_url
    click_on "New cheat sheet"

    fill_in "Description", with: @cheat_sheet.description
    fill_in "Title", with: @cheat_sheet.title
    click_on "Create Cheat sheet"

    assert_text "Cheat sheet was successfully created"
    click_on "Back"
  end

  test "should update Cheat sheet" do
    visit cheat_sheet_url(@cheat_sheet)
    click_on "Edit this cheat sheet", match: :first

    fill_in "Description", with: @cheat_sheet.description
    fill_in "Title", with: @cheat_sheet.title
    click_on "Update Cheat sheet"

    assert_text "Cheat sheet was successfully updated"
    click_on "Back"
  end

  test "should destroy Cheat sheet" do
    visit cheat_sheet_url(@cheat_sheet)
    click_on "Destroy this cheat sheet", match: :first

    assert_text "Cheat sheet was successfully destroyed"
  end
end
