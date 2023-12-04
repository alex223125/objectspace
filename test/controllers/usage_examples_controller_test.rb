require "test_helper"

class UsageExamplesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usage_example = usage_examples(:one)
  end

  test "should get index" do
    get usage_examples_url
    assert_response :success
  end

  test "should get new" do
    get new_usage_example_url
    assert_response :success
  end

  test "should create usage_example" do
    assert_difference("UsageExample.count") do
      post usage_examples_url, params: { usage_example: {  } }
    end

    assert_redirected_to usage_example_url(UsageExample.last)
  end

  test "should show usage_example" do
    get usage_example_url(@usage_example)
    assert_response :success
  end

  test "should get edit" do
    get edit_usage_example_url(@usage_example)
    assert_response :success
  end

  test "should update usage_example" do
    patch usage_example_url(@usage_example), params: { usage_example: {  } }
    assert_redirected_to usage_example_url(@usage_example)
  end

  test "should destroy usage_example" do
    assert_difference("UsageExample.count", -1) do
      delete usage_example_url(@usage_example)
    end

    assert_redirected_to usage_examples_url
  end
end
