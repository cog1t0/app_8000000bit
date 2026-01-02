# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_13_121500) do
  create_table "bingo_cards", force: :cascade do |t|
    t.string "token", null: false
    t.string "title", null: false
    t.json "items", default: [], null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_bingo_cards_on_token", unique: true
  end

  create_table "diagnosis_results", force: :cascade do |t|
    t.string "token"
    t.integer "meishiki_master_id", null: false
    t.string "fortune_type"
    t.text "memo"
    t.text "ai_summary"
    t.text "ai_advice"
    t.boolean "accessed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tmp_password"
    t.datetime "tmp_password_expires_at"
    t.index ["meishiki_master_id"], name: "index_diagnosis_results_on_meishiki_master_id"
    t.index ["tmp_password"], name: "index_diagnosis_results_on_tmp_password"
  end

  create_table "meishiki_masters", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.integer "day"
    t.string "sex"
    t.string "tenchu_1"
    t.string "tenchu_2"
    t.string "kanshi_day_k_info_1"
    t.string "kanshi_day_k_info_2"
    t.string "kanshi_day_k_info_3"
    t.string "kanshi_month_k_info_1"
    t.string "kanshi_month_k_info_2"
    t.string "kanshi_month_k_info_3"
    t.string "kanshi_year_k_info_1"
    t.string "kanshi_year_k_info_2"
    t.string "kanshi_year_k_info_3"
    t.string "kanshi_no_day"
    t.string "kanshi_no_month"
    t.string "kanshi_no_year"
    t.string "zokan_day"
    t.string "zokan_month"
    t.string "zokan_year"
    t.string "tsuhen_day"
    t.string "tsuhen_month"
    t.string "tsuhen_year"
    t.string "ztsuhen_day"
    t.string "ztsuhen_month"
    t.string "ztsuhen_year"
    t.string "unsei12_day"
    t.string "unsei12_month"
    t.string "unsei12_year"
    t.string "energy_kei"
    t.string "energy_day"
    t.string "energy_month"
    t.string "energy_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year", "month", "day", "sex"], name: "index_meishiki_masters_on_year_and_month_and_day_and_sex", unique: true
  end

  add_foreign_key "diagnosis_results", "meishiki_masters"
end
