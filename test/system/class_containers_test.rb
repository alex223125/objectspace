require "application_system_test_case"

class ClassContainersTest < ApplicationSystemTestCase
  setup do
    @class_container = class_containers(:one)
  end

  test "visiting the index" do
    visit class_containers_url
    assert_selector "h1", text: "Class containers"
  end

  test "should create class container" do
    visit class_containers_url
    click_on "New class container"

    fill_in "Description", with: @class_container.description
    fill_in "Title", with: @class_container.title
    click_on "Create Class container"

    assert_text "Class container was successfully created"
    click_on "Back"
  end

  test "should update Class container" do
    visit class_container_url(@class_container)
    click_on "Edit this class container", match: :first

    fill_in "Description", with: @class_container.description
    fill_in "Title", with: @class_container.title
    click_on "Update Class container"

    assert_text "Class container was successfully updated"
    click_on "Back"
  end

  test "should destroy Class container" do
    visit class_container_url(@class_container)
    click_on "Destroy this class container", match: :first

    assert_text "Class container was successfully destroyed"
  end
end
