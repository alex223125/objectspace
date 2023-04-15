require "application_system_test_case"

class SimpleObjectsTest < ApplicationSystemTestCase
  setup do
    @simple_object = simple_objects(:one)
  end

  test "visiting the index" do
    visit simple_objects_url
    assert_selector "h1", text: "Simple objects"
  end

  test "should create simple object" do
    visit simple_objects_url
    click_on "New simple object"

    fill_in "Description", with: @simple_object.description
    fill_in "Title", with: @simple_object.title
    click_on "Create Simple object"

    assert_text "Simple object was successfully created"
    click_on "Back"
  end

  test "should update Simple object" do
    visit simple_object_url(@simple_object)
    click_on "Edit this simple object", match: :first

    fill_in "Description", with: @simple_object.description
    fill_in "Title", with: @simple_object.title
    click_on "Update Simple object"

    assert_text "Simple object was successfully updated"
    click_on "Back"
  end

  test "should destroy Simple object" do
    visit simple_object_url(@simple_object)
    click_on "Destroy this simple object", match: :first

    assert_text "Simple object was successfully destroyed"
  end
end
