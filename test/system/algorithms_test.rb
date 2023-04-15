require "application_system_test_case"

class AlgorithmsTest < ApplicationSystemTestCase
  setup do
    @algorithm = algorithms(:one)
  end

  test "visiting the index" do
    visit algorithms_url
    assert_selector "h1", text: "Algorithms"
  end

  test "should create algorithm" do
    visit algorithms_url
    click_on "New algorithm"

    fill_in "Description", with: @algorithm.description
    fill_in "Title", with: @algorithm.title
    click_on "Create Algorithm"

    assert_text "Algorithm was successfully created"
    click_on "Back"
  end

  test "should update Algorithm" do
    visit algorithm_url(@algorithm)
    click_on "Edit this algorithm", match: :first

    fill_in "Description", with: @algorithm.description
    fill_in "Title", with: @algorithm.title
    click_on "Update Algorithm"

    assert_text "Algorithm was successfully updated"
    click_on "Back"
  end

  test "should destroy Algorithm" do
    visit algorithm_url(@algorithm)
    click_on "Destroy this algorithm", match: :first

    assert_text "Algorithm was successfully destroyed"
  end
end
