require "test_helper"

class CheatSheetGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cheat_sheet_group = cheat_sheet_groups(:one)
  end

  test "should get index" do
    get cheat_sheet_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_cheat_sheet_group_url
    assert_response :success
  end

  test "should create cheat_sheet_group" do
    assert_difference("CheatSheetGroup.count") do
      post cheat_sheet_groups_url, params: { cheat_sheet_group: { description: @cheat_sheet_group.description, title: @cheat_sheet_group.title } }
    end

    assert_redirected_to cheat_sheet_group_url(CheatSheetGroup.last)
  end

  test "should show cheat_sheet_group" do
    get cheat_sheet_group_url(@cheat_sheet_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_cheat_sheet_group_url(@cheat_sheet_group)
    assert_response :success
  end

  test "should update cheat_sheet_group" do
    patch cheat_sheet_group_url(@cheat_sheet_group), params: { cheat_sheet_group: { description: @cheat_sheet_group.description, title: @cheat_sheet_group.title } }
    assert_redirected_to cheat_sheet_group_url(@cheat_sheet_group)
  end

  test "should destroy cheat_sheet_group" do
    assert_difference("CheatSheetGroup.count", -1) do
      delete cheat_sheet_group_url(@cheat_sheet_group)
    end

    assert_redirected_to cheat_sheet_groups_url
  end
end
