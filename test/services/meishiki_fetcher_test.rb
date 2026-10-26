require "test_helper"
require "minitest/mock"
require "tempfile"

class MeishikiFetcherTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    @previous = ENV.to_h.slice("MEISHIKI_FETCHER_INSECURE", "SSL_CA_FILE")
    ENV["MEISHIKI_FETCHER_INSECURE"] = "1"
    ENV.delete("SSL_CA_FILE")
    @http = Net::HTTP.new("example.invalid", 443)
  end

  teardown do
    %w[MEISHIKI_FETCHER_INSECURE SSL_CA_FILE].each do |key|
      @previous.key?(key) ? ENV[key] = @previous[key] : ENV.delete(key)
    end
  end

  test "legacy insecure setting cannot bypass TLS certificate verification" do
    request = ->(_request) do
      assert_predicate @http, :use_ssl?
      assert_equal OpenSSL::SSL::VERIFY_PEER, @http.verify_mode
      raise OpenSSL::SSL::SSLError, "certificate verify failed"
    end

    Net::HTTP.stub(:new, @http) do
      @http.stub(:request, request) do
        assert_raises(OpenSSL::SSL::SSLError) { fetch_html }
      end
    end
  end

  test "custom CA files remain available with peer verification enabled" do
    Tempfile.create("meishiki-ca") do |file|
      ENV["SSL_CA_FILE"] = file.path
      store = OpenSSL::X509::Store.new
      loaded_ca_files = []
      store.define_singleton_method(:add_file) { |path| loaded_ca_files << path }
      response = Net::HTTPOK.new("1.1", "200", "OK")
      response.define_singleton_method(:body) { "verified response" }
      request = ->(_request) do
        assert_same store, @http.cert_store
        assert_equal OpenSSL::SSL::VERIFY_PEER, @http.verify_mode
        response
      end

      OpenSSL::X509::Store.stub(:new, store) do
        Net::HTTP.stub(:new, @http) do
          @http.stub(:request, request) { assert_equal "verified response", fetch_html }
        end
      end
      assert_equal [ file.path ], loaded_ca_files
    end
  end

  private

  def fetch_html
    MeishikiFetcher.fetch_html(year: 2000, month: 1, day: 1, sex: "1")
  end
end
