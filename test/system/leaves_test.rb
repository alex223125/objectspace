require "application_system_test_case"

class LeavesTest < ApplicationSystemTestCase
  setup do
    @leafe = leaves(:one)
  end

  test "visiting the index" do
    visit leaves_url
    assert_selector "h1", text: "Leaves"
  end

  test "should create leafe" do
    visit leaves_url
    click_on "New leafe"

    fill_in "Node title", with: @leafe.node_title
    click_on "Create Leafe"

    assert_text "Leafe was successfully created"
    click_on "Back"
  end

  test "should update Leafe" do
    visit leafe_url(@leafe)
    click_on "Edit this leafe", match: :first

    fill_in "Node title", with: @leafe.node_title
    click_on "Update Leafe"

    assert_text "Leafe was successfully updated"
    click_on "Back"
  end

  test "should destroy Leafe" do
    visit leafe_url(@leafe)
    click_on "Destroy this leafe", match: :first

    assert_text "Leafe was successfully destroyed"
  end
end
