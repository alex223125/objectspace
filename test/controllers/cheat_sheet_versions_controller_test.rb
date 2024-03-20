require "test_helper"

class CheatSheetVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cheat_sheet_version = cheat_sheet_versions(:one)
  end

  test "should get index" do
    get cheat_sheet_versions_url
    assert_response :success
  end

  test "should get new" do
    get new_cheat_sheet_version_url
    assert_response :success
  end

  test "should create cheat_sheet_version" do
    assert_difference("CheatSheetVersion.count") do
      post cheat_sheet_versions_url, params: { cheat_sheet_version: { description: @cheat_sheet_version.description, title: @cheat_sheet_version.title } }
    end

    assert_redirected_to cheat_sheet_version_url(CheatSheetVersion.last)
  end

  test "should show cheat_sheet_version" do
    get cheat_sheet_version_url(@cheat_sheet_version)
    assert_response :success
  end

  test "should get edit" do
    get edit_cheat_sheet_version_url(@cheat_sheet_version)
    assert_response :success
  end

  test "should update cheat_sheet_version" do
    patch cheat_sheet_version_url(@cheat_sheet_version), params: { cheat_sheet_version: { description: @cheat_sheet_version.description, title: @cheat_sheet_version.title } }
    assert_redirected_to cheat_sheet_version_url(@cheat_sheet_version)
  end

  test "should destroy cheat_sheet_version" do
    assert_difference("CheatSheetVersion.count", -1) do
      delete cheat_sheet_version_url(@cheat_sheet_version)
    end

    assert_redirected_to cheat_sheet_versions_url
  end
end
