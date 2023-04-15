require "application_system_test_case"

class ImprovementsTest < ApplicationSystemTestCase
  setup do
    @improvement = improvements(:one)
  end

  test "visiting the index" do
    visit improvements_url
    assert_selector "h1", text: "Improvements"
  end

  test "should create improvement" do
    visit improvements_url
    click_on "New improvement"

    fill_in "Content", with: @improvement.content
    fill_in "Sources", with: @improvement.sources
    fill_in "Title", with: @improvement.title
    click_on "Create Improvement"

    assert_text "Improvement was successfully created"
    click_on "Back"
  end

  test "should update Improvement" do
    visit improvement_url(@improvement)
    click_on "Edit this improvement", match: :first

    fill_in "Content", with: @improvement.content
    fill_in "Sources", with: @improvement.sources
    fill_in "Title", with: @improvement.title
    click_on "Update Improvement"

    assert_text "Improvement was successfully updated"
    click_on "Back"
  end

  test "should destroy Improvement" do
    visit improvement_url(@improvement)
    click_on "Destroy this improvement", match: :first

    assert_text "Improvement was successfully destroyed"
  end
end
