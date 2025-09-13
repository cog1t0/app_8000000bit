class DiagnosisResult < ApplicationRecord
  belongs_to :meishiki_master

  validates :token, :fortune_type, presence: true
  validates :token, uniqueness: true
end
