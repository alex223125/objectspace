require "test_helper"

class UnitUsageExamplesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit_usage_example = unit_usage_examples(:one)
  end

  test "should get index" do
    get unit_usage_examples_url
    assert_response :success
  end

  test "should get new" do
    get new_unit_usage_example_url
    assert_response :success
  end

  test "should create unit_usage_example" do
    assert_difference("UnitUsageExample.count") do
      post unit_usage_examples_url, params: { unit_usage_example: { description: @unit_usage_example.description, sources: @unit_usage_example.sources, title: @unit_usage_example.title } }
    end

    assert_redirected_to unit_usage_example_url(UnitUsageExample.last)
  end

  test "should show unit_usage_example" do
    get unit_usage_example_url(@unit_usage_example)
    assert_response :success
  end

  test "should get edit" do
    get edit_unit_usage_example_url(@unit_usage_example)
    assert_response :success
  end

  test "should update unit_usage_example" do
    patch unit_usage_example_url(@unit_usage_example), params: { unit_usage_example: { description: @unit_usage_example.description, sources: @unit_usage_example.sources, title: @unit_usage_example.title } }
    assert_redirected_to unit_usage_example_url(@unit_usage_example)
  end

  test "should destroy unit_usage_example" do
    assert_difference("UnitUsageExample.count", -1) do
      delete unit_usage_example_url(@unit_usage_example)
    end

    assert_redirected_to unit_usage_examples_url
  end
end
