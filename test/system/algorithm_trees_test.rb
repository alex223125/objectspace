require "application_system_test_case"

class AlgorithmTreesTest < ApplicationSystemTestCase
  setup do
    @algorithm_tree = algorithm_trees(:one)
  end

  test "visiting the index" do
    visit algorithm_trees_url
    assert_selector "h1", text: "Algorithm trees"
  end

  test "should create algorithm tree" do
    visit algorithm_trees_url
    click_on "New algorithm tree"

    fill_in "Algorithm version title", with: @algorithm_tree.algorithm_version_title
    click_on "Create Algorithm tree"

    assert_text "Algorithm tree was successfully created"
    click_on "Back"
  end

  test "should update Algorithm tree" do
    visit algorithm_tree_url(@algorithm_tree)
    click_on "Edit this algorithm tree", match: :first

    fill_in "Algorithm version title", with: @algorithm_tree.algorithm_version_title
    click_on "Update Algorithm tree"

    assert_text "Algorithm tree was successfully updated"
    click_on "Back"
  end

  test "should destroy Algorithm tree" do
    visit algorithm_tree_url(@algorithm_tree)
    click_on "Destroy this algorithm tree", match: :first

    assert_text "Algorithm tree was successfully destroyed"
  end
end
