require "test_helper"

class InterfaceMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @interface_member = interface_members(:one)
  end

  test "should get index" do
    get interface_members_url
    assert_response :success
  end

  test "should get new" do
    get new_interface_member_url
    assert_response :success
  end

  test "should create interface_member" do
    assert_difference("InterfaceMember.count") do
      post interface_members_url, params: { interface_member: {  } }
    end

    assert_redirected_to interface_member_url(InterfaceMember.last)
  end

  test "should show interface_member" do
    get interface_member_url(@interface_member)
    assert_response :success
  end

  test "should get edit" do
    get edit_interface_member_url(@interface_member)
    assert_response :success
  end

  test "should update interface_member" do
    patch interface_member_url(@interface_member), params: { interface_member: {  } }
    assert_redirected_to interface_member_url(@interface_member)
  end

  test "should destroy interface_member" do
    assert_difference("InterfaceMember.count", -1) do
      delete interface_member_url(@interface_member)
    end

    assert_redirected_to interface_members_url
  end
end
