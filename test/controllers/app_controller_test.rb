require "test_helper"

class AppControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/"
    assert_response :success
    assert_select "#work h2", text: "試していること"
    assert_select "#work p", text: /VRや電子工作にもチャレンジ中/
    assert_select "#work a", count: 0
    assert_no_match(/ミコトナビ|命式|四柱推命/, response.body)
  end
end
