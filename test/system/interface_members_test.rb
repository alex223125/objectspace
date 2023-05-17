require "application_system_test_case"

class InterfaceMembersTest < ApplicationSystemTestCase
  setup do
    @interface_member = interface_members(:one)
  end

  test "visiting the index" do
    visit interface_members_url
    assert_selector "h1", text: "Interface members"
  end

  test "should create interface member" do
    visit interface_members_url
    click_on "New interface member"

    click_on "Create Interface member"

    assert_text "Interface member was successfully created"
    click_on "Back"
  end

  test "should update Interface member" do
    visit interface_member_url(@interface_member)
    click_on "Edit this interface member", match: :first

    click_on "Update Interface member"

    assert_text "Interface member was successfully updated"
    click_on "Back"
  end

  test "should destroy Interface member" do
    visit interface_member_url(@interface_member)
    click_on "Destroy this interface member", match: :first

    assert_text "Interface member was successfully destroyed"
  end
end
