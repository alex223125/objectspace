require "test_helper"

class LoggingNodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @logging_node = logging_nodes(:one)
  end

  test "should get index" do
    get logging_nodes_url
    assert_response :success
  end

  test "should get new" do
    get new_logging_node_url
    assert_response :success
  end

  test "should create logging_node" do
    assert_difference("LoggingNode.count") do
      post logging_nodes_url, params: { logging_node: { position: @logging_node.position, type: @logging_node.type } }
    end

    assert_redirected_to logging_node_url(LoggingNode.last)
  end

  test "should show logging_node" do
    get logging_node_url(@logging_node)
    assert_response :success
  end

  test "should get edit" do
    get edit_logging_node_url(@logging_node)
    assert_response :success
  end

  test "should update logging_node" do
    patch logging_node_url(@logging_node), params: { logging_node: { position: @logging_node.position, type: @logging_node.type } }
    assert_redirected_to logging_node_url(@logging_node)
  end

  test "should destroy logging_node" do
    assert_difference("LoggingNode.count", -1) do
      delete logging_node_url(@logging_node)
    end

    assert_redirected_to logging_nodes_url
  end
end
