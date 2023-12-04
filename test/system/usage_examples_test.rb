require "application_system_test_case"

class UsageExamplesTest < ApplicationSystemTestCase
  setup do
    @usage_example = usage_examples(:one)
  end

  test "visiting the index" do
    visit usage_examples_url
    assert_selector "h1", text: "Usage examples"
  end

  test "should create usage example" do
    visit usage_examples_url
    click_on "New usage example"

    click_on "Create Usage example"

    assert_text "Usage example was successfully created"
    click_on "Back"
  end

  test "should update Usage example" do
    visit usage_example_url(@usage_example)
    click_on "Edit this usage example", match: :first

    click_on "Update Usage example"

    assert_text "Usage example was successfully updated"
    click_on "Back"
  end

  test "should destroy Usage example" do
    visit usage_example_url(@usage_example)
    click_on "Destroy this usage example", match: :first

    assert_text "Usage example was successfully destroyed"
  end
end
