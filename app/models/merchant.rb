class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.find_by_merchant_name(param)
    return all unless param.present?
    return where("name ILIKE ?", "%#{param}%")
  end
end
