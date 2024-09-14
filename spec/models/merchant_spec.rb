require 'rails_helper'

RSpec.describe Merchant do
  describe 'relationships' do
    it {should have_many :invoices}
    it {should have_many :items}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
  end

  describe 'sorting newest merchants first by age' do
    it "gets a list of all merchants in descending order" do
      merchant_1 = Merchant.create!(name: "Walmart")
      merchant_2 = Merchant.create!(name: "Target")
      merchant_3 = Merchant.create!(name: "Sam's")

      sorted_merchants = Merchant.sort_direction('age')
          
      expect(sorted_merchants).to eq([merchant_1, merchant_2, merchant_3])
    end
  end

end