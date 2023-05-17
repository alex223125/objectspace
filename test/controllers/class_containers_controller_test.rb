require "test_helper"

class ClassContainersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @class_container = class_containers(:one)
  end

  test "should get index" do
    get class_containers_url
    assert_response :success
  end

  test "should get new" do
    get new_class_container_url
    assert_response :success
  end

  test "should create class_container" do
    assert_difference("ClassContainer.count") do
      post class_containers_url, params: { class_container: { description: @class_container.description, title: @class_container.title } }
    end

    assert_redirected_to class_container_url(ClassContainer.last)
  end

  test "should show class_container" do
    get class_container_url(@class_container)
    assert_response :success
  end

  test "should get edit" do
    get edit_class_container_url(@class_container)
    assert_response :success
  end

  test "should update class_container" do
    patch class_container_url(@class_container), params: { class_container: { description: @class_container.description, title: @class_container.title } }
    assert_redirected_to class_container_url(@class_container)
  end

  test "should destroy class_container" do
    assert_difference("ClassContainer.count", -1) do
      delete class_container_url(@class_container)
    end

    assert_redirected_to class_containers_url
  end
end
