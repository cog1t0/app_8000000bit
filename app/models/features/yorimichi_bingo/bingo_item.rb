module Features
  module YorimichiBingo
    class BingoItem < ApplicationRecord
      self.table_name = "bingo_items"

      belongs_to :bingo_category, class_name: "Features::YorimichiBingo::BingoCategory", inverse_of: :bingo_items

      delegate :slug, :display_name, to: :bingo_category, prefix: :category

      scope :active, -> { where(active: true) }

      validates :title, presence: true
    end
  end
end
