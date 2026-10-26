require "test_helper"

class RetiredRabbitHoleRoutesTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "retired Rabbit Hole endpoints are no longer routable" do
    [ [ :get, "/rabbit-hole" ], [ :post, "/rabbit-hole" ],
      [ :get, "/rabbit-hole/created" ], [ :get, "/rabbit-hole-form" ] ].each do |method, path|
      assert_raises(ActionController::RoutingError) do
        Rails.application.routes.recognize_path(path, method: method)
      end
    end
  end
end
