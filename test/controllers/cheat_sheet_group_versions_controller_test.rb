require "test_helper"

class CheatSheetGroupVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cheat_sheet_group_version = cheat_sheet_group_versions(:one)
  end

  test "should get index" do
    get cheat_sheet_group_versions_url
    assert_response :success
  end

  test "should get new" do
    get new_cheat_sheet_group_version_url
    assert_response :success
  end

  test "should create cheat_sheet_group_version" do
    assert_difference("CheatSheetGroupVersion.count") do
      post cheat_sheet_group_versions_url, params: { cheat_sheet_group_version: { description: @cheat_sheet_group_version.description, title: @cheat_sheet_group_version.title } }
    end

    assert_redirected_to cheat_sheet_group_version_url(CheatSheetGroupVersion.last)
  end

  test "should show cheat_sheet_group_version" do
    get cheat_sheet_group_version_url(@cheat_sheet_group_version)
    assert_response :success
  end

  test "should get edit" do
    get edit_cheat_sheet_group_version_url(@cheat_sheet_group_version)
    assert_response :success
  end

  test "should update cheat_sheet_group_version" do
    patch cheat_sheet_group_version_url(@cheat_sheet_group_version), params: { cheat_sheet_group_version: { description: @cheat_sheet_group_version.description, title: @cheat_sheet_group_version.title } }
    assert_redirected_to cheat_sheet_group_version_url(@cheat_sheet_group_version)
  end

  test "should destroy cheat_sheet_group_version" do
    assert_difference("CheatSheetGroupVersion.count", -1) do
      delete cheat_sheet_group_version_url(@cheat_sheet_group_version)
    end

    assert_redirected_to cheat_sheet_group_versions_url
  end
end
