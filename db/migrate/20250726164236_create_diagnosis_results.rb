class CreateDiagnosisResults < ActiveRecord::Migration[8.0]
  def change
    create_table :diagnosis_results do |t|
      t.string :token
      t.references :meishiki_master, null: false, foreign_key: true
      t.string :fortune_type
      t.text :memo
      t.text :ai_summary
      t.text :ai_advice
      t.boolean :accessed

      t.timestamps
    end
  end
end
