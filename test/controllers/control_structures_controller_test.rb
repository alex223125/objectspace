require "test_helper"

class ControlStructuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @control_structure = control_structures(:one)
  end

  test "should get index" do
    get control_structures_url
    assert_response :success
  end

  test "should get new" do
    get new_control_structure_url
    assert_response :success
  end

  test "should create control_structure" do
    assert_difference("ControlStructure.count") do
      post control_structures_url, params: { control_structure: { type: @control_structure.type } }
    end

    assert_redirected_to control_structure_url(ControlStructure.last)
  end

  test "should show control_structure" do
    get control_structure_url(@control_structure)
    assert_response :success
  end

  test "should get edit" do
    get edit_control_structure_url(@control_structure)
    assert_response :success
  end

  test "should update control_structure" do
    patch control_structure_url(@control_structure), params: { control_structure: { type: @control_structure.type } }
    assert_redirected_to control_structure_url(@control_structure)
  end

  test "should destroy control_structure" do
    assert_difference("ControlStructure.count", -1) do
      delete control_structure_url(@control_structure)
    end

    assert_redirected_to control_structures_url
  end
end
