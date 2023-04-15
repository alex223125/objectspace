require "test_helper"

class SubstepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @substep = substeps(:one)
  end

  test "should get index" do
    get substeps_url
    assert_response :success
  end

  test "should get new" do
    get new_substep_url
    assert_response :success
  end

  test "should create substep" do
    assert_difference("Substep.count") do
      post substeps_url, params: { substep: { type: @substep.type } }
    end

    assert_redirected_to substep_url(Substep.last)
  end

  test "should show substep" do
    get substep_url(@substep)
    assert_response :success
  end

  test "should get edit" do
    get edit_substep_url(@substep)
    assert_response :success
  end

  test "should update substep" do
    patch substep_url(@substep), params: { substep: { type: @substep.type } }
    assert_redirected_to substep_url(@substep)
  end

  test "should destroy substep" do
    assert_difference("Substep.count", -1) do
      delete substep_url(@substep)
    end

    assert_redirected_to substeps_url
  end
end
