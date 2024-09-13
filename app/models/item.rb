class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items

  def self.sort_price(param)
    return order(unit_price: :asc) if param == "price"
    return all
  end

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: { only_float: true}
  validates :merchant_id, presence: true, numericality: {only_integer: true}
end