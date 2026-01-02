require "test_helper"
require "ostruct"

module Features
  module YorimichiBingo
    class BingoCheckerTest < ActiveSupport::TestCase
      self.fixture_table_names = []

      def setup
        @base_items = (1..25).map do |i|
          { "id" => i, "title" => "cell #{i}", "checked" => false, "checked_at" => nil }
        end
      end

      test "counts checked cells" do
        items = dup_items
        items.first(3).each { |item| item["checked"] = true }

        checker = BingoChecker.new(OpenStruct.new(items: items))
        assert_equal 3, checker.checked_count
        assert_equal 0, checker.bingo_count
      end

      test "detects row bingo" do
        items = dup_items
        (0...5).each { |idx| items[idx]["checked"] = true }

        checker = BingoChecker.new(OpenStruct.new(items: items))
        assert_equal 1, checker.bingo_count
      end

      test "detects column and diagonal bingos" do
        items = dup_items
        [0, 5, 10, 15, 20].each { |idx| items[idx]["checked"] = true }
        [4, 8, 12, 16, 20].each { |idx| items[idx]["checked"] = true }

        checker = BingoChecker.new(OpenStruct.new(items: items))
        assert_equal 2, checker.bingo_count
      end

      private

      def dup_items
        @base_items.map(&:dup)
      end
    end
  end
end
