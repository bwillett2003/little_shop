class Customer < ApplicationRecord
  has_many :invoices

  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.filter_merchant_id(params)
    Customer.joins(:invoices).where("merchant_id = #{params}").distinct
  end
end