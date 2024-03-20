require "test_helper"

class CheatSheetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cheat_sheet = cheat_sheets(:one)
  end

  test "should get index" do
    get cheat_sheets_url
    assert_response :success
  end

  test "should get new" do
    get new_cheat_sheet_url
    assert_response :success
  end

  test "should create cheat_sheet" do
    assert_difference("CheatSheet.count") do
      post cheat_sheets_url, params: { cheat_sheet: { description: @cheat_sheet.description, title: @cheat_sheet.title } }
    end

    assert_redirected_to cheat_sheet_url(CheatSheet.last)
  end

  test "should show cheat_sheet" do
    get cheat_sheet_url(@cheat_sheet)
    assert_response :success
  end

  test "should get edit" do
    get edit_cheat_sheet_url(@cheat_sheet)
    assert_response :success
  end

  test "should update cheat_sheet" do
    patch cheat_sheet_url(@cheat_sheet), params: { cheat_sheet: { description: @cheat_sheet.description, title: @cheat_sheet.title } }
    assert_redirected_to cheat_sheet_url(@cheat_sheet)
  end

  test "should destroy cheat_sheet" do
    assert_difference("CheatSheet.count", -1) do
      delete cheat_sheet_url(@cheat_sheet)
    end

    assert_redirected_to cheat_sheets_url
  end
end
