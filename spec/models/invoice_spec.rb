require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationships' do
    it {should belong_to :customer}
    it {should belong_to :merchant}
    it {should have_many :invoice_items}
    it {should have_many :transactions}
  end

  describe 'validations' do
    it {should validate_presence_of(:item_id)}
    it {should validate_numericality_of(:item_id)}
    it {should validate_presence_of(:invoice_id)}
    it {should validate_numericality_of(:invoice_id)}
    it {should validate_presence_of(:quantity)}
    it {should validate_numericality_of(:quantity)}
    it {shoud validate_presence_of(:unit_price)}
    it {should validate_numericality_of(:unit_price)}
  end
end