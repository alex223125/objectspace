require "application_system_test_case"

class ArticleVersionsTest < ApplicationSystemTestCase
  setup do
    @article_version = article_versions(:one)
  end

  test "visiting the index" do
    visit article_versions_url
    assert_selector "h1", text: "Article versions"
  end

  test "should create article version" do
    visit article_versions_url
    click_on "New article version"

    fill_in "Additional information", with: @article_version.additional_information
    fill_in "Content", with: @article_version.content
    fill_in "Solves the problem", with: @article_version.solves_the_problem
    fill_in "Sources", with: @article_version.sources
    fill_in "Title", with: @article_version.title
    click_on "Create Article version"

    assert_text "Article version was successfully created"
    click_on "Back"
  end

  test "should update Article version" do
    visit article_version_url(@article_version)
    click_on "Edit this article version", match: :first

    fill_in "Additional information", with: @article_version.additional_information
    fill_in "Content", with: @article_version.content
    fill_in "Solves the problem", with: @article_version.solves_the_problem
    fill_in "Sources", with: @article_version.sources
    fill_in "Title", with: @article_version.title
    click_on "Update Article version"

    assert_text "Article version was successfully updated"
    click_on "Back"
  end

  test "should destroy Article version" do
    visit article_version_url(@article_version)
    click_on "Destroy this article version", match: :first

    assert_text "Article version was successfully destroyed"
  end
end
