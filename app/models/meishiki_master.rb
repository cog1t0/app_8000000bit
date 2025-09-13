class MeishikiMaster < ApplicationRecord
  has_many :diagnosis_results, dependent: :destroy

  validates :year, :month, :day, :sex, presence: true
  validates :year, :month, :day, :sex, uniqueness: { scope: [ :year, :month, :day, :sex ] }
end
