require "test_helper"

class InterfaceGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @interface_group = interface_groups(:one)
  end

  test "should get index" do
    get interface_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_interface_group_url
    assert_response :success
  end

  test "should create interface_group" do
    assert_difference("InterfaceGroup.count") do
      post interface_groups_url, params: { interface_group: { description: @interface_group.description, title: @interface_group.title } }
    end

    assert_redirected_to interface_group_url(InterfaceGroup.last)
  end

  test "should show interface_group" do
    get interface_group_url(@interface_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_interface_group_url(@interface_group)
    assert_response :success
  end

  test "should update interface_group" do
    patch interface_group_url(@interface_group), params: { interface_group: { description: @interface_group.description, title: @interface_group.title } }
    assert_redirected_to interface_group_url(@interface_group)
  end

  test "should destroy interface_group" do
    assert_difference("InterfaceGroup.count", -1) do
      delete interface_group_url(@interface_group)
    end

    assert_redirected_to interface_groups_url
  end
end
