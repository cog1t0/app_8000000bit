require "test_helper"
require "tmpdir"

class EmiKarutaTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []
  self.use_transactional_tests = false

  setup do
    @previous = ENV.values_at("EMI_KARUTA_USERNAME", "EMI_KARUTA_PASSWORD")
    ENV["EMI_KARUTA_USERNAME"] = "test-neighborhood"
    ENV["EMI_KARUTA_PASSWORD"] = "test-only-password"
    @authorization = ActionController::HttpAuthentication::Basic.encode_credentials("test-neighborhood", "test-only-password")
    @data_directory = Pathname.new(Dir.mktmpdir("emi-karuta-test"))
    Emi::KarutaController::PRIVATE_FILES.each { |name| @data_directory.join(name).write("// private test fixture") }
    @original_directory = Emi::KarutaController.instance_method(:private_directory)
    directory = @data_directory
    Emi::KarutaController.define_method(:private_directory) { directory }
    Emi::KarutaController.send(:private, :private_directory)
  end

  teardown do
    Emi::KarutaController.define_method(:private_directory, @original_directory)
    Emi::KarutaController.send(:private, :private_directory)
    %w[EMI_KARUTA_USERNAME EMI_KARUTA_PASSWORD].zip(@previous).each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    FileUtils.remove_entry(@data_directory)
  end

  test "homepage is public and links to authenticated game" do
    get "/emi"
    assert_response :success
    assert_select "html[lang=ja]"
    assert_select "a[href='/emi/karuta']", text: /かるたで/
  end

  test "page and every data or code URL require authentication for GET and HEAD" do
    urls = [ "/emi/karuta" ] + (Emi::KarutaController::PRIVATE_FILES + Emi::KarutaController::CODE_FILES.keys).map { |n| "/emi/karuta/files/#{n}" }
    urls.each do |url|
      [ :get, :head ].each do |method|
        public_send(method, url)
        assert_response :unauthorized
        assert_match "Basic", response.headers["WWW-Authenticate"]
        assert_includes response.headers["Cache-Control"], "no-store"
      end
    end
  end

  test "wrong username or password is denied" do
    [ [ "wrong", "test-only-password" ], [ "test-neighborhood", "wrong" ] ].each do |user, password|
      get "/emi/karuta", headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
      assert_response :unauthorized
    end
  end

  test "malformed basic credentials return unauthorized for page and assets" do
    [ "Basic #{Base64.strict_encode64('test-neighborhood')}", "Basic #{Base64.strict_encode64(':')}", "Basic !!!", "Basic " ].each do |authorization|
      [ "/emi/karuta", "/emi/karuta/files/app.js" ].each do |url|
        get url, headers: { "Authorization" => authorization, "Sec-Fetch-Site" => "same-origin" }
        assert_response :unauthorized
        assert_match "Basic", response.headers["WWW-Authenticate"]
      end
    end
  end

  test "missing credentials fail closed" do
    %w[EMI_KARUTA_USERNAME EMI_KARUTA_PASSWORD].each do |key|
      saved = ENV.delete(key)
      get "/emi/karuta", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
      assert_response :service_unavailable
      get "/emi/karuta/files/card-images.js", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
      assert_response :service_unavailable
      ENV[key] = saved
    end
  end

  test "authenticated page and bundled media are available without external services" do
    get "/emi/karuta", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
    assert_response :success
    assert_select "button#start"
    assert_select "label input#import[type=file]:not([hidden])", count: 1
    assert_select "script[src^='/emi/karuta/files/']", count: 5
    assert_select "a.brand[href='/emi']"
    get "/emi/karuta/files/card-images.js", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
    assert_response :success
    assert_equal "// private test fixture", response.body
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]
    get "/emi/karuta/files/style.css", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
    assert_response :success
    assert_no_match(/@import|https:\/\//, response.body)
    assert_match(/\A:root\s*\{/, response.body)
    assert_includes response.body, "--green:#365844"
  end

  test "cross-site script embedding is denied even with credentials" do
    [ nil, "cross-site", "same-site" ].each do |site|
      headers = { "Authorization" => @authorization }
      headers["Sec-Fetch-Site"] = site if site
      get "/emi/karuta/files/card-images.js", headers: headers
      assert_response :forbidden
    end
  end

  test "missing private data and unlisted files are not exposed" do
    @data_directory.join("reading-audio.js").delete
    get "/emi/karuta", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
    assert_response :service_unavailable
    [ "reading-audio.js", "offline.html", "credentials.yml.enc", "..%2F..%2Fconfig%2Fdatabase.yml" ].each do |name|
      get "/emi/karuta/files/#{name}", headers: { "Authorization" => @authorization, "Sec-Fetch-Site" => "same-origin" }
      assert_response :not_found
    end
    get "/storage/emi_karuta/topics.js"
    assert_response :not_found
  end
end
