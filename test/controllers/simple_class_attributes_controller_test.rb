require "test_helper"

class SimpleClassAttributesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @simple_class_attribute = simple_class_attributes(:one)
  end

  test "should get index" do
    get simple_class_attributes_url
    assert_response :success
  end

  test "should get new" do
    get new_simple_class_attribute_url
    assert_response :success
  end

  test "should create simple_class_attribute" do
    assert_difference("SimpleClassAttribute.count") do
      post simple_class_attributes_url, params: { simple_class_attribute: {  } }
    end

    assert_redirected_to simple_class_attribute_url(SimpleClassAttribute.last)
  end

  test "should show simple_class_attribute" do
    get simple_class_attribute_url(@simple_class_attribute)
    assert_response :success
  end

  test "should get edit" do
    get edit_simple_class_attribute_url(@simple_class_attribute)
    assert_response :success
  end

  test "should update simple_class_attribute" do
    patch simple_class_attribute_url(@simple_class_attribute), params: { simple_class_attribute: {  } }
    assert_redirected_to simple_class_attribute_url(@simple_class_attribute)
  end

  test "should destroy simple_class_attribute" do
    assert_difference("SimpleClassAttribute.count", -1) do
      delete simple_class_attribute_url(@simple_class_attribute)
    end

    assert_redirected_to simple_class_attributes_url
  end
end
