require "test_helper"

class SimpleClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @simple_class = simple_classes(:one)
  end

  test "should get index" do
    get simple_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_simple_class_url
    assert_response :success
  end

  test "should create simple_class" do
    assert_difference("SimpleClass.count") do
      post simple_classes_url, params: { simple_class: {  } }
    end

    assert_redirected_to simple_class_url(SimpleClass.last)
  end

  test "should show simple_class" do
    get simple_class_url(@simple_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_simple_class_url(@simple_class)
    assert_response :success
  end

  test "should update simple_class" do
    patch simple_class_url(@simple_class), params: { simple_class: {  } }
    assert_redirected_to simple_class_url(@simple_class)
  end

  test "should destroy simple_class" do
    assert_difference("SimpleClass.count", -1) do
      delete simple_class_url(@simple_class)
    end

    assert_redirected_to simple_classes_url
  end
end
