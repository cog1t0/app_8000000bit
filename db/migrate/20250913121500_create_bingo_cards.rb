class CreateBingoCards < ActiveRecord::Migration[8.0]
  def change
    create_table :bingo_cards do |t|
      t.string :token, null: false
      t.string :title, null: false
      t.json :items, null: false, default: []
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :bingo_cards, :token, unique: true
  end
end
