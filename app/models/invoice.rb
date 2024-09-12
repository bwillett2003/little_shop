class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items
  has_many :transactions

  validates :customer_id, presence: true, numericality: {only_integer: true}
  validates :merchant_id, presence: true, numericality: {only_interger: true}
  validates :status, presence: true
end