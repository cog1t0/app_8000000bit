module Features
  module YorimichiBingo
    class BingoCategory < ApplicationRecord
      self.table_name = "bingo_categories"

      has_many :bingo_items, class_name: "Features::YorimichiBingo::BingoItem", dependent: :destroy, inverse_of: :bingo_category

      validates :slug, presence: true, uniqueness: true
      validates :display_name, presence: true

      scope :active, -> { all } # 予備（将来カテゴリの有効/無効を追加したくなったとき用）
    end
  end
end
