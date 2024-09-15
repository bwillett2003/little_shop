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
          
      expect(sorted_merchants).to eq([merchant_3, merchant_2, merchant_1])
    end
  end

  describe "sort with nothing passed" do
    it "returns all merchants without sort is blank" do
      merchant_1 = Merchant.create!(name: "Walmart", created_at: 1.day.ago)
      merchant_2 = Merchant.create!(name: "Target", created_at: Time.current)

      sorted_merchants = Merchant.sort_direction(nil)

      expect(sorted_merchants).to include(merchant_1, merchant_2)
    end
  end

  describe "filter returned invoices" do
    it  "returns merchants with items from an invoice returned" do
      merchant_1 = Merchant.create!(name: "Walmart")
      merchant_2 = Merchant.create!(name: "Target")

      customer_1 = Customer.create!(first_name: "Luke", last_name: "Skywalker")
      customer_2 = Customer.create!(first_name: "Harry", last_name: "Potter")

      Invoice.create!(merchant:  merchant_1, status: "returned", customer: customer_1)
      Invoice.create!(merchant: merchant_2, status: "paid", customer: customer_2)

      filter_merchants = Merchant.filter_returned("returned")

      expect(filter_merchants).to include(merchant_1)
      expect(filter_merchants).not_to include(merchant_2)
    end

    describe "return all when no return invoices found" do
      it "returns all merchants when there are no returned invoices" do
        merchant_1 = Merchant.create!(name: "Walmart")
        merchant_2 = Merchant.create!(name: "Target")

        customer_1 = Customer.create!(first_name: "Luke", last_name: "Skywalker")
        customer_2 = Customer.create!(first_name: "Harry", last_name: "Potter")

        Invoice.create!(merchant:  merchant_1, status: "paid", customer: customer_1)
        Invoice.create!(merchant: merchant_2, status: "paid", customer: customer_2)

        filter_merchants = Merchant.filter_returned("paid")

        expect(filter_merchants).to include(merchant_1, merchant_2)
      end
    end
  end

end