require "application_system_test_case"

class InterfaceGroupsTest < ApplicationSystemTestCase
  setup do
    @interface_group = interface_groups(:one)
  end

  test "visiting the index" do
    visit interface_groups_url
    assert_selector "h1", text: "Interface groups"
  end

  test "should create interface group" do
    visit interface_groups_url
    click_on "New interface group"

    fill_in "Description", with: @interface_group.description
    fill_in "Title", with: @interface_group.title
    click_on "Create Interface group"

    assert_text "Interface group was successfully created"
    click_on "Back"
  end

  test "should update Interface group" do
    visit interface_group_url(@interface_group)
    click_on "Edit this interface group", match: :first

    fill_in "Description", with: @interface_group.description
    fill_in "Title", with: @interface_group.title
    click_on "Update Interface group"

    assert_text "Interface group was successfully updated"
    click_on "Back"
  end

  test "should destroy Interface group" do
    visit interface_group_url(@interface_group)
    click_on "Destroy this interface group", match: :first

    assert_text "Interface group was successfully destroyed"
  end
end
