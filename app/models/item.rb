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

  def self.find_by_name(param)
    return all unless param.present?
    return where("name ILIKE ?", "%#{param}%").first
  end

  def self.find_by_min_price(param)
    return all unless param.present?
    return where('unit_price >= ?', param).order(:name)
  end

  def self.find_by_max_price(param)
    return all unless param.present?
    return where('unit_price <= ?', param).order(:name)
  end
end