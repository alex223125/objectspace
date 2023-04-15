require "application_system_test_case"

class UnitUsageExamplesTest < ApplicationSystemTestCase
  setup do
    @unit_usage_example = unit_usage_examples(:one)
  end

  test "visiting the index" do
    visit unit_usage_examples_url
    assert_selector "h1", text: "Unit usage examples"
  end

  test "should create unit usage example" do
    visit unit_usage_examples_url
    click_on "New unit usage example"

    fill_in "Description", with: @unit_usage_example.description
    fill_in "Sources", with: @unit_usage_example.sources
    fill_in "Title", with: @unit_usage_example.title
    click_on "Create Unit usage example"

    assert_text "Unit usage example was successfully created"
    click_on "Back"
  end

  test "should update Unit usage example" do
    visit unit_usage_example_url(@unit_usage_example)
    click_on "Edit this unit usage example", match: :first

    fill_in "Description", with: @unit_usage_example.description
    fill_in "Sources", with: @unit_usage_example.sources
    fill_in "Title", with: @unit_usage_example.title
    click_on "Update Unit usage example"

    assert_text "Unit usage example was successfully updated"
    click_on "Back"
  end

  test "should destroy Unit usage example" do
    visit unit_usage_example_url(@unit_usage_example)
    click_on "Destroy this unit usage example", match: :first

    assert_text "Unit usage example was successfully destroyed"
  end
end
