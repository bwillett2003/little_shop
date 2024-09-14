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

  describe 'sorting methods' do
    it "gets a list of all merchants in ascending order" do
      merchant_1 = Merchant.create!(name: "Walmart")
      merchant_2 = Merchant.create!(name: "Target")
      merchant_3 = Merchant.create!(name: "Sam's")

      sorted_merchants = Merchant.sort_direction('asc')
          
      expect(sorted_merchants).to eq([merchant_1, merchant_2, merchant_3])
    end

    it "gets a list of all merchants in descending order" do
      merchant_1 = Merchant.create!(name: "Walmart")
      merchant_2 = Merchant.create!(name: "Target")
      merchant_3 = Merchant.create!(name: "Sam's")

      sorted_merchants = Merchant.sort_direction('desc')
          
      expect(sorted_merchants).to eq([merchant_3, merchant_2, merchant_1])
    end
  end

end