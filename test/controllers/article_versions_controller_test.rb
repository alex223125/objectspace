require "test_helper"

class ArticleVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article_version = article_versions(:one)
  end

  test "should get index" do
    get article_versions_url
    assert_response :success
  end

  test "should get new" do
    get new_article_version_url
    assert_response :success
  end

  test "should create article_version" do
    assert_difference("ArticleVersion.count") do
      post article_versions_url, params: { article_version: { additional_information: @article_version.additional_information, content: @article_version.content, solves_the_problem: @article_version.solves_the_problem, sources: @article_version.sources, title: @article_version.title } }
    end

    assert_redirected_to article_version_url(ArticleVersion.last)
  end

  test "should show article_version" do
    get article_version_url(@article_version)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_version_url(@article_version)
    assert_response :success
  end

  test "should update article_version" do
    patch article_version_url(@article_version), params: { article_version: { additional_information: @article_version.additional_information, content: @article_version.content, solves_the_problem: @article_version.solves_the_problem, sources: @article_version.sources, title: @article_version.title } }
    assert_redirected_to article_version_url(@article_version)
  end

  test "should destroy article_version" do
    assert_difference("ArticleVersion.count", -1) do
      delete article_version_url(@article_version)
    end

    assert_redirected_to article_versions_url
  end
end
