module Features
  module YorimichiBingo
    class BingoChecker
      GRID_SIZE = 5

      def initialize(bingo_card)
        @items = bingo_card.items || []
      end

      def checked_count
        @items.count { |item| item["checked"] }
      end

      def bingo_count
        lines.count { |line| line.all? { |item| item["checked"] } }
      end

      private

      def lines
        return [] unless complete_grid?

        rows + columns + diagonals
      end

      def rows
        @items.each_slice(GRID_SIZE).to_a
      end

      def columns
        rows.transpose
      end

      def diagonals
        grid = rows
        left_to_right = (0...GRID_SIZE).map { |i| grid[i][i] }
        right_to_left = (0...GRID_SIZE).map { |i| grid[i][GRID_SIZE - 1 - i] }
        [left_to_right, right_to_left]
      end

      def complete_grid?
        @items.size == GRID_SIZE * GRID_SIZE
      end
    end
  end
end
