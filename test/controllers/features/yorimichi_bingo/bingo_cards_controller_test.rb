require "test_helper"

module Features
  module YorimichiBingo
    class BingoCardsControllerTest < ActionDispatch::IntegrationTest
      self.fixture_table_names = []

      test "expired card cannot be toggled" do
        card = BingoCard.create!(
          title: "expired",
          items: build_items,
          expires_at: 1.day.ago
        )

        patch yorimichi_bingo_toggle_path(token: card.token), params: { id: 1 }
        assert_redirected_to yorimichi_bingo_card_path(token: card.token)
        assert_equal "期限が切れたカードは更新できません。", flash[:alert]

        card.reload
        refute card.items.first["checked"], "expired card should not update items"
      end

      test "reset issues a new card with same title" do
        card = BingoCard.create!(
          title: "Reset me",
          items: build_items,
          expires_at: 5.days.from_now
        )

        assert_difference -> { BingoCard.count }, +1 do
          post yorimichi_bingo_reset_path(token: card.token)
        end

        new_card = BingoCard.order(:created_at).last
        assert_redirected_to yorimichi_bingo_card_path(token: new_card.token)
        assert_equal "Reset me", new_card.title
        assert_not_equal card.token, new_card.token
        assert_equal 25, new_card.items.size
      end

      private

      def build_items
        (1..25).map { |i| { "id" => i, "title" => "cell #{i}", "checked" => false, "checked_at" => nil } }
      end
    end
  end
end
