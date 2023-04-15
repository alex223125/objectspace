require "test_helper"

class AlgorithmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @algorithm = algorithms(:one)
  end

  test "should get index" do
    get algorithms_url
    assert_response :success
  end

  test "should get new" do
    get new_algorithm_url
    assert_response :success
  end

  test "should create algorithm" do
    assert_difference("Algorithm.count") do
      post algorithms_url, params: { algorithm: { description: @algorithm.description, title: @algorithm.title } }
    end

    assert_redirected_to algorithm_url(Algorithm.last)
  end

  test "should show algorithm" do
    get algorithm_url(@algorithm)
    assert_response :success
  end

  test "should get edit" do
    get edit_algorithm_url(@algorithm)
    assert_response :success
  end

  test "should update algorithm" do
    patch algorithm_url(@algorithm), params: { algorithm: { description: @algorithm.description, title: @algorithm.title } }
    assert_redirected_to algorithm_url(@algorithm)
  end

  test "should destroy algorithm" do
    assert_difference("Algorithm.count", -1) do
      delete algorithm_url(@algorithm)
    end

    assert_redirected_to algorithms_url
  end
end
