class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items

  validates :name, presence: true, uniqueness: true
end
