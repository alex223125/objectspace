require "application_system_test_case"

class SimpleClassesTest < ApplicationSystemTestCase
  setup do
    @simple_class = simple_classes(:one)
  end

  test "visiting the index" do
    visit simple_classes_url
    assert_selector "h1", text: "Simple classes"
  end

  test "should create simple class" do
    visit simple_classes_url
    click_on "New simple class"

    click_on "Create Simple class"

    assert_text "Simple class was successfully created"
    click_on "Back"
  end

  test "should update Simple class" do
    visit simple_class_url(@simple_class)
    click_on "Edit this simple class", match: :first

    click_on "Update Simple class"

    assert_text "Simple class was successfully updated"
    click_on "Back"
  end

  test "should destroy Simple class" do
    visit simple_class_url(@simple_class)
    click_on "Destroy this simple class", match: :first

    assert_text "Simple class was successfully destroyed"
  end
end
