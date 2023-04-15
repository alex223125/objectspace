require "test_helper"

class ImprovementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @improvement = improvements(:one)
  end

  test "should get index" do
    get improvements_url
    assert_response :success
  end

  test "should get new" do
    get new_improvement_url
    assert_response :success
  end

  test "should create improvement" do
    assert_difference("Improvement.count") do
      post improvements_url, params: { improvement: { content: @improvement.content, sources: @improvement.sources, title: @improvement.title } }
    end

    assert_redirected_to improvement_url(Improvement.last)
  end

  test "should show improvement" do
    get improvement_url(@improvement)
    assert_response :success
  end

  test "should get edit" do
    get edit_improvement_url(@improvement)
    assert_response :success
  end

  test "should update improvement" do
    patch improvement_url(@improvement), params: { improvement: { content: @improvement.content, sources: @improvement.sources, title: @improvement.title } }
    assert_redirected_to improvement_url(@improvement)
  end

  test "should destroy improvement" do
    assert_difference("Improvement.count", -1) do
      delete improvement_url(@improvement)
    end

    assert_redirected_to improvements_url
  end
end
