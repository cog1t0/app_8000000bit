require "test_helper"

class AppControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get app_index_url
    assert_response :success
  end

  test "should get history" do
    get history_url
    assert_response :success
  end

  test "should post search" do
    post search_url, params: { lat: "0", lon: "0", category: "history" }
    assert_response :success
  end
end
