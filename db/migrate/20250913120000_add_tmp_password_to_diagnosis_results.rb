class AddTmpPasswordToDiagnosisResults < ActiveRecord::Migration[8.0]
  def change
    add_column :diagnosis_results, :tmp_password, :string
    add_column :diagnosis_results, :tmp_password_expires_at, :datetime
    add_index :diagnosis_results, :tmp_password
  end
end