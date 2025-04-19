require "application_system_test_case"

class SimpleClassInterfacesTest < ApplicationSystemTestCase
  setup do
    @simple_class_interface = simple_class_interfaces(:one)
  end

  test "visiting the index" do
    visit simple_class_interfaces_url
    assert_selector "h1", text: "Simple class interfaces"
  end

  test "should create simple class interface" do
    visit simple_class_interfaces_url
    click_on "New simple class interface"

    fill_in "Note", with: @simple_class_interface.note
    click_on "Create Simple class interface"

    assert_text "Simple class interface was successfully created"
    click_on "Back"
  end

  test "should update Simple class interface" do
    visit simple_class_interface_url(@simple_class_interface)
    click_on "Edit this simple class interface", match: :first

    fill_in "Note", with: @simple_class_interface.note
    click_on "Update Simple class interface"

    assert_text "Simple class interface was successfully updated"
    click_on "Back"
  end

  test "should destroy Simple class interface" do
    visit simple_class_interface_url(@simple_class_interface)
    click_on "Destroy this simple class interface", match: :first

    assert_text "Simple class interface was successfully destroyed"
  end
end
