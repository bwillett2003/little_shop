class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items, dependent: :destroy

  def self.sort_direction(sort)   
    return order(created_at: :desc) if sort == "age"
    return all
  end

  def self.filter_returned(status)
    return joins(:invoices).where(invoices: {status: "returned"}).distinct if status == "returned"
    return all
 
  end

  validates :name, presence: true, uniqueness: true

  def self.find_by_merchant_name(param)
    return all unless param.present?
    return where("name ILIKE ?", "%#{param}%")
  end
end
