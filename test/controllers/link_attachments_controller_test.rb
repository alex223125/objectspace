require "test_helper"

class LinkAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @link_attachment = link_attachments(:one)
  end

  test "should get index" do
    get link_attachments_url
    assert_response :success
  end

  test "should get new" do
    get new_link_attachment_url
    assert_response :success
  end

  test "should create link_attachment" do
    assert_difference("LinkAttachment.count") do
      post link_attachments_url, params: { link_attachment: {  } }
    end

    assert_redirected_to link_attachment_url(LinkAttachment.last)
  end

  test "should show link_attachment" do
    get link_attachment_url(@link_attachment)
    assert_response :success
  end

  test "should get edit" do
    get edit_link_attachment_url(@link_attachment)
    assert_response :success
  end

  test "should update link_attachment" do
    patch link_attachment_url(@link_attachment), params: { link_attachment: {  } }
    assert_redirected_to link_attachment_url(@link_attachment)
  end

  test "should destroy link_attachment" do
    assert_difference("LinkAttachment.count", -1) do
      delete link_attachment_url(@link_attachment)
    end

    assert_redirected_to link_attachments_url
  end
end
