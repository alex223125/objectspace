require "test_helper"

class Ecosystems::LoadSources::Actors::ActorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ecosystems_load_sources_actors_actors_index_url
    assert_response :success
  end

  test "should get show" do
    get ecosystems_load_sources_actors_actors_show_url
    assert_response :success
  end

  test "should get new" do
    get ecosystems_load_sources_actors_actors_new_url
    assert_response :success
  end

  test "should get edit" do
    get ecosystems_load_sources_actors_actors_edit_url
    assert_response :success
  end
end
