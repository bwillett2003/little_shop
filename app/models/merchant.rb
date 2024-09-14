class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items, dependent: :destroy

  def self.sort_direction(sort)   
    return order(created_at: :desc) if sort == 'age'
    return all
  end

  validates :name, presence: true, uniqueness: true
end
