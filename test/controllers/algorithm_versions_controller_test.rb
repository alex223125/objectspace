require "test_helper"

class AlgorithmVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @algorithm_version = algorithm_versions(:one)
  end

  test "should get index" do
    get algorithm_versions_url
    assert_response :success
  end

  test "should get new" do
    get new_algorithm_version_url
    assert_response :success
  end

  test "should create algorithm_version" do
    assert_difference("AlgorithmVersion.count") do
      post algorithm_versions_url, params: { algorithm_version: { additional_information: @algorithm_version.additional_information, solves_the_problem: @algorithm_version.solves_the_problem, sources: @algorithm_version.sources, title: @algorithm_version.title } }
    end

    assert_redirected_to algorithm_version_url(AlgorithmVersion.last)
  end

  test "should show algorithm_version" do
    get algorithm_version_url(@algorithm_version)
    assert_response :success
  end

  test "should get edit" do
    get edit_algorithm_version_url(@algorithm_version)
    assert_response :success
  end

  test "should update algorithm_version" do
    patch algorithm_version_url(@algorithm_version), params: { algorithm_version: { additional_information: @algorithm_version.additional_information, solves_the_problem: @algorithm_version.solves_the_problem, sources: @algorithm_version.sources, title: @algorithm_version.title } }
    assert_redirected_to algorithm_version_url(@algorithm_version)
  end

  test "should destroy algorithm_version" do
    assert_difference("AlgorithmVersion.count", -1) do
      delete algorithm_version_url(@algorithm_version)
    end

    assert_redirected_to algorithm_versions_url
  end
end
