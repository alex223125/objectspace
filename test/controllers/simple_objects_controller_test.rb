require "test_helper"

class SimpleObjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @simple_object = simple_objects(:one)
  end

  test "should get index" do
    get simple_objects_url
    assert_response :success
  end

  test "should get new" do
    get new_simple_object_url
    assert_response :success
  end

  test "should create simple_object" do
    assert_difference("SimpleObject.count") do
      post simple_objects_url, params: { simple_object: { description: @simple_object.description, title: @simple_object.title } }
    end

    assert_redirected_to simple_object_url(SimpleObject.last)
  end

  test "should show simple_object" do
    get simple_object_url(@simple_object)
    assert_response :success
  end

  test "should get edit" do
    get edit_simple_object_url(@simple_object)
    assert_response :success
  end

  test "should update simple_object" do
    patch simple_object_url(@simple_object), params: { simple_object: { description: @simple_object.description, title: @simple_object.title } }
    assert_redirected_to simple_object_url(@simple_object)
  end

  test "should destroy simple_object" do
    assert_difference("SimpleObject.count", -1) do
      delete simple_object_url(@simple_object)
    end

    assert_redirected_to simple_objects_url
  end
end
