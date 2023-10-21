require "application_system_test_case"

class SimpleClassAttributesTest < ApplicationSystemTestCase
  setup do
    @simple_class_attribute = simple_class_attributes(:one)
  end

  test "visiting the index" do
    visit simple_class_attributes_url
    assert_selector "h1", text: "Simple class attributes"
  end

  test "should create simple class attribute" do
    visit simple_class_attributes_url
    click_on "New simple class attribute"

    click_on "Create Simple class attribute"

    assert_text "Simple class attribute was successfully created"
    click_on "Back"
  end

  test "should update Simple class attribute" do
    visit simple_class_attribute_url(@simple_class_attribute)
    click_on "Edit this simple class attribute", match: :first

    click_on "Update Simple class attribute"

    assert_text "Simple class attribute was successfully updated"
    click_on "Back"
  end

  test "should destroy Simple class attribute" do
    visit simple_class_attribute_url(@simple_class_attribute)
    click_on "Destroy this simple class attribute", match: :first

    assert_text "Simple class attribute was successfully destroyed"
  end
end
