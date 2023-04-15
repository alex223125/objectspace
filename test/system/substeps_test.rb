require "application_system_test_case"

class SubstepsTest < ApplicationSystemTestCase
  setup do
    @substep = substeps(:one)
  end

  test "visiting the index" do
    visit substeps_url
    assert_selector "h1", text: "Substeps"
  end

  test "should create substep" do
    visit substeps_url
    click_on "New substep"

    fill_in "Type", with: @substep.type
    click_on "Create Substep"

    assert_text "Substep was successfully created"
    click_on "Back"
  end

  test "should update Substep" do
    visit substep_url(@substep)
    click_on "Edit this substep", match: :first

    fill_in "Type", with: @substep.type
    click_on "Update Substep"

    assert_text "Substep was successfully updated"
    click_on "Back"
  end

  test "should destroy Substep" do
    visit substep_url(@substep)
    click_on "Destroy this substep", match: :first

    assert_text "Substep was successfully destroyed"
  end
end
