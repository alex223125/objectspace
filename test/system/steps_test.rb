require "application_system_test_case"

class StepsTest < ApplicationSystemTestCase
  setup do
    @step = steps(:one)
  end

  test "visiting the index" do
    visit steps_url
    assert_selector "h1", text: "Steps"
  end

  test "should create step" do
    visit steps_url
    click_on "New step"

    fill_in "Instruction", with: @step.instruction
    fill_in "Title", with: @step.title
    click_on "Create Step"

    assert_text "Step was successfully created"
    click_on "Back"
  end

  test "should update Step" do
    visit step_url(@step)
    click_on "Edit this step", match: :first

    fill_in "Instruction", with: @step.instruction
    fill_in "Title", with: @step.title
    click_on "Update Step"

    assert_text "Step was successfully updated"
    click_on "Back"
  end

  test "should destroy Step" do
    visit step_url(@step)
    click_on "Destroy this step", match: :first

    assert_text "Step was successfully destroyed"
  end
end
