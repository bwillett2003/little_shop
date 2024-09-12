require 'rails_helper'

RSpec.describe Item do
  describe 'relationships' do
    it {should belong_to :merchant}
    it {should have_many :invoice_items}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_uniquness_of(:name)}
    it {should validate_presence_of(:description)}
    it {should validate_presence_of(:unit_price)}
    it {should validate_numericality_of(:unit_price)}
    it {should validate_presence_of(:merchant_id)}
    it {should validate_numricality_of(:merchant_id)}
  end
end