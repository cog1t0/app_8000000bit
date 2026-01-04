module Features
  module YorimichiBingo
    class BingoCard < ApplicationRecord
      self.table_name = "bingo_cards"

      TOKEN_LENGTH = 8

      before_validation :ensure_token

      validates :token, presence: true, uniqueness: true, length: { is: TOKEN_LENGTH }
      validates :title, presence: true
      validates :items, presence: true
      validates :expires_at, presence: true

      def expired?
        expires_at.present? && expires_at <= Time.current
      end

      def setup_completed?
        setup_completed_at.present?
      end

      def selected_category_slugs
        super || []
      end

      private

      def ensure_token
        return if token.present?

        self.token = generate_unique_token
      end

      def generate_unique_token
        loop do
          candidate = SecureRandom.alphanumeric(TOKEN_LENGTH).upcase
          break candidate unless self.class.exists?(token: candidate)
        end
      end
    end
  end
end
