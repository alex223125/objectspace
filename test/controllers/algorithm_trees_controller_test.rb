require "test_helper"

class AlgorithmTreesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @algorithm_tree = algorithm_trees(:one)
  end

  test "should get index" do
    get algorithm_trees_url
    assert_response :success
  end

  test "should get new" do
    get new_algorithm_tree_url
    assert_response :success
  end

  test "should create algorithm_tree" do
    assert_difference("AlgorithmTree.count") do
      post algorithm_trees_url, params: { algorithm_tree: { algorithm_version_title: @algorithm_tree.algorithm_version_title } }
    end

    assert_redirected_to algorithm_tree_url(AlgorithmTree.last)
  end

  test "should show algorithm_tree" do
    get algorithm_tree_url(@algorithm_tree)
    assert_response :success
  end

  test "should get edit" do
    get edit_algorithm_tree_url(@algorithm_tree)
    assert_response :success
  end

  test "should update algorithm_tree" do
    patch algorithm_tree_url(@algorithm_tree), params: { algorithm_tree: { algorithm_version_title: @algorithm_tree.algorithm_version_title } }
    assert_redirected_to algorithm_tree_url(@algorithm_tree)
  end

  test "should destroy algorithm_tree" do
    assert_difference("AlgorithmTree.count", -1) do
      delete algorithm_tree_url(@algorithm_tree)
    end

    assert_redirected_to algorithm_trees_url
  end
end
