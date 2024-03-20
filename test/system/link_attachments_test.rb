require "application_system_test_case"

class LinkAttachmentsTest < ApplicationSystemTestCase
  setup do
    @link_attachment = link_attachments(:one)
  end

  test "visiting the index" do
    visit link_attachments_url
    assert_selector "h1", text: "Link attachments"
  end

  test "should create link attachment" do
    visit link_attachments_url
    click_on "New link attachment"

    click_on "Create Link attachment"

    assert_text "Link attachment was successfully created"
    click_on "Back"
  end

  test "should update Link attachment" do
    visit link_attachment_url(@link_attachment)
    click_on "Edit this link attachment", match: :first

    click_on "Update Link attachment"

    assert_text "Link attachment was successfully updated"
    click_on "Back"
  end

  test "should destroy Link attachment" do
    visit link_attachment_url(@link_attachment)
    click_on "Destroy this link attachment", match: :first

    assert_text "Link attachment was successfully destroyed"
  end
end
