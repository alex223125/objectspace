require "application_system_test_case"

class ContainerMembersTest < ApplicationSystemTestCase
  setup do
    @container_member = container_members(:one)
  end

  test "visiting the index" do
    visit container_members_url
    assert_selector "h1", text: "Container members"
  end

  test "should create container member" do
    visit container_members_url
    click_on "New container member"

    click_on "Create Container member"

    assert_text "Container member was successfully created"
    click_on "Back"
  end

  test "should update Container member" do
    visit container_member_url(@container_member)
    click_on "Edit this container member", match: :first

    click_on "Update Container member"

    assert_text "Container member was successfully updated"
    click_on "Back"
  end

  test "should destroy Container member" do
    visit container_member_url(@container_member)
    click_on "Destroy this container member", match: :first

    assert_text "Container member was successfully destroyed"
  end
end
