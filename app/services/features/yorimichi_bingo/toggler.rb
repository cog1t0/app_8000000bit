module Features
  module YorimichiBingo
    class Toggler
      def initialize(bingo_card, cell_id)
        @bingo_card = bingo_card
        @cell_id = cell_id.to_i
      end

      def call
        updated_items = @bingo_card.items.map do |item|
          item["id"] == @cell_id ? toggle_item(item) : item
        end

        @bingo_card.update!(items: updated_items)
        @bingo_card
      end

      private

      def toggle_item(item)
        checked = !!item["checked"]
        if checked
          item.merge("checked" => false, "checked_at" => nil)
        else
          item.merge("checked" => true, "checked_at" => Time.current)
        end
      end
    end
  end
end
