require "test_helper"

class ContainerMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @container_member = container_members(:one)
  end

  test "should get index" do
    get container_members_url
    assert_response :success
  end

  test "should get new" do
    get new_container_member_url
    assert_response :success
  end

  test "should create container_member" do
    assert_difference("ContainerMember.count") do
      post container_members_url, params: { container_member: {  } }
    end

    assert_redirected_to container_member_url(ContainerMember.last)
  end

  test "should show container_member" do
    get container_member_url(@container_member)
    assert_response :success
  end

  test "should get edit" do
    get edit_container_member_url(@container_member)
    assert_response :success
  end

  test "should update container_member" do
    patch container_member_url(@container_member), params: { container_member: {  } }
    assert_redirected_to container_member_url(@container_member)
  end

  test "should destroy container_member" do
    assert_difference("ContainerMember.count", -1) do
      delete container_member_url(@container_member)
    end

    assert_redirected_to container_members_url
  end
end
