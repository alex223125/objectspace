require "application_system_test_case"

class LoggingNodesTest < ApplicationSystemTestCase
  setup do
    @logging_node = logging_nodes(:one)
  end

  test "visiting the index" do
    visit logging_nodes_url
    assert_selector "h1", text: "Logging nodes"
  end

  test "should create logging node" do
    visit logging_nodes_url
    click_on "New logging node"

    fill_in "Position", with: @logging_node.position
    fill_in "Type", with: @logging_node.type
    click_on "Create Logging node"

    assert_text "Logging node was successfully created"
    click_on "Back"
  end

  test "should update Logging node" do
    visit logging_node_url(@logging_node)
    click_on "Edit this logging node", match: :first

    fill_in "Position", with: @logging_node.position
    fill_in "Type", with: @logging_node.type
    click_on "Update Logging node"

    assert_text "Logging node was successfully updated"
    click_on "Back"
  end

  test "should destroy Logging node" do
    visit logging_node_url(@logging_node)
    click_on "Destroy this logging node", match: :first

    assert_text "Logging node was successfully destroyed"
  end
end
