require "application_system_test_case"

class ControlStructuresTest < ApplicationSystemTestCase
  setup do
    @control_structure = control_structures(:one)
  end

  test "visiting the index" do
    visit control_structures_url
    assert_selector "h1", text: "Control structures"
  end

  test "should create control structure" do
    visit control_structures_url
    click_on "New control structure"

    fill_in "Type", with: @control_structure.type
    click_on "Create Control structure"

    assert_text "Control structure was successfully created"
    click_on "Back"
  end

  test "should update Control structure" do
    visit control_structure_url(@control_structure)
    click_on "Edit this control structure", match: :first

    fill_in "Type", with: @control_structure.type
    click_on "Update Control structure"

    assert_text "Control structure was successfully updated"
    click_on "Back"
  end

  test "should destroy Control structure" do
    visit control_structure_url(@control_structure)
    click_on "Destroy this control structure", match: :first

    assert_text "Control structure was successfully destroyed"
  end
end
