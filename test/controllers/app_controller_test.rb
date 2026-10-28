require "test_helper"

class AppControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/"
    assert_response :success
    assert_select "#work h2", text: "試していること"
    assert_select "#work p", text: /Webアプリや電子工作を試し/
    assert_select "#work .yao-work-note", count: 2
    assert_select '#work a[href="https://note.com/8000000bit/n/n36f4b1d9888d"]', count: 1
    assert_select '#work a[href="https://note.com/8000000bit/n/n9ee4e17cb193"]', count: 1
    assert_no_match(/ミコトナビ|命式|四柱推命/, response.body)
    assert_select ".yao-respect, .yao-about-lead, .yao-footer", count: 0
    assert_select ".yao-section-heading", count: 3
    assert_select "#about p", text: /出雲出身。経済学部/
    assert_select "#about p", text: /技術顧問として、ミコトNaviの開発/
    assert_select '#about a[href="https://x.com/r19_tech"][target="_blank"]', count: 1
    assert_select '#about a[href="https://note.com/8000000bit"]', count: 1
  end
end
