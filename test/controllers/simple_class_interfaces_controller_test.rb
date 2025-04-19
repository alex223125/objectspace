require "test_helper"

class SimpleClassInterfacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @simple_class_interface = simple_class_interfaces(:one)
  end

  test "should get index" do
    get simple_class_interfaces_url
    assert_response :success
  end

  test "should get new" do
    get new_simple_class_interface_url
    assert_response :success
  end

  test "should create simple_class_interface" do
    assert_difference("SimpleClassInterface.count") do
      post simple_class_interfaces_url, params: { simple_class_interface: { note: @simple_class_interface.note } }
    end

    assert_redirected_to simple_class_interface_url(SimpleClassInterface.last)
  end

  test "should show simple_class_interface" do
    get simple_class_interface_url(@simple_class_interface)
    assert_response :success
  end

  test "should get edit" do
    get edit_simple_class_interface_url(@simple_class_interface)
    assert_response :success
  end

  test "should update simple_class_interface" do
    patch simple_class_interface_url(@simple_class_interface), params: { simple_class_interface: { note: @simple_class_interface.note } }
    assert_redirected_to simple_class_interface_url(@simple_class_interface)
  end

  test "should destroy simple_class_interface" do
    assert_difference("SimpleClassInterface.count", -1) do
      delete simple_class_interface_url(@simple_class_interface)
    end

    assert_redirected_to simple_class_interfaces_url
  end
end
