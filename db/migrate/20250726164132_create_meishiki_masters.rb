class CreateMeishikiMasters < ActiveRecord::Migration[8.0]
  def change
    create_table :meishiki_masters do |t|
      t.integer :year
      t.integer :month
      t.integer :day
      t.string :sex
      t.string :tenchu_1
      t.string :tenchu_2
      t.string :kanshi_day_k_info_1
      t.string :kanshi_day_k_info_2
      t.string :kanshi_day_k_info_3
      t.string :kanshi_month_k_info_1
      t.string :kanshi_month_k_info_2
      t.string :kanshi_month_k_info_3
      t.string :kanshi_year_k_info_1
      t.string :kanshi_year_k_info_2
      t.string :kanshi_year_k_info_3
      t.string :kanshi_no_day
      t.string :kanshi_no_month
      t.string :kanshi_no_year
      t.string :zokan_day
      t.string :zokan_month
      t.string :zokan_year
      t.string :tsuhen_day
      t.string :tsuhen_month
      t.string :tsuhen_year
      t.string :ztsuhen_day
      t.string :ztsuhen_month
      t.string :ztsuhen_year
      t.string :unsei12_day
      t.string :unsei12_month
      t.string :unsei12_year
      t.string :energy_kei
      t.string :energy_day
      t.string :energy_month
      t.string :energy_year

      t.timestamps
    end

    add_index :meishiki_masters, [ :year, :month, :day, :sex ], unique: true
  end
end
