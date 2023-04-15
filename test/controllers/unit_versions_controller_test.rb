require "test_helper"

class UnitVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit_version = unit_versions(:one)
  end

  test "should get index" do
    get unit_versions_url
    assert_response :success
  end

  test "should get new" do
    get new_unit_version_url
    assert_response :success
  end

  test "should create unit_version" do
    assert_difference("UnitVersion.count") do
      post unit_versions_url, params: { unit_version: { additional_information: @unit_version.additional_information, instruction: @unit_version.instruction, solves_the_problem: @unit_version.solves_the_problem, sources: @unit_version.sources, title: @unit_version.title } }
    end

    assert_redirected_to unit_version_url(UnitVersion.last)
  end

  test "should show unit_version" do
    get unit_version_url(@unit_version)
    assert_response :success
  end

  test "should get edit" do
    get edit_unit_version_url(@unit_version)
    assert_response :success
  end

  test "should update unit_version" do
    patch unit_version_url(@unit_version), params: { unit_version: { additional_information: @unit_version.additional_information, instruction: @unit_version.instruction, solves_the_problem: @unit_version.solves_the_problem, sources: @unit_version.sources, title: @unit_version.title } }
    assert_redirected_to unit_version_url(@unit_version)
  end

  test "should destroy unit_version" do
    assert_difference("UnitVersion.count", -1) do
      delete unit_version_url(@unit_version)
    end

    assert_redirected_to unit_versions_url
  end
end
