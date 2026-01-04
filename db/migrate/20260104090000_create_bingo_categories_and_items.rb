class CreateBingoCategoriesAndItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bingo_categories do |t|
      t.string :slug, null: false
      t.string :display_name, null: false
      t.text :description

      t.timestamps
    end
    add_index :bingo_categories, :slug, unique: true

    create_table :bingo_items do |t|
      t.references :bingo_category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :illustration
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
