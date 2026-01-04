class AddSetupFieldsToBingoCards < ActiveRecord::Migration[8.0]
  def change
    add_column :bingo_cards, :selected_category_slugs, :json, null: false, default: []
    add_column :bingo_cards, :setup_completed_at, :datetime

    reversible do |dir|
      dir.up do
        bingo_card_class.reset_column_information
        bingo_card_class.where(selected_category_slugs: nil).update_all(selected_category_slugs: [])
        bingo_card_class.where(setup_completed_at: nil).update_all("setup_completed_at = COALESCE(updated_at, created_at, CURRENT_TIMESTAMP)")
      end
    end
  end

  private

  def bingo_card_class
    @bingo_card_class ||= Class.new(ApplicationRecord) do
      self.table_name = "bingo_cards"
    end
  end
end
