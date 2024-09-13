class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
