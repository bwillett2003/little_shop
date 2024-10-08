require 'rails_helper'

RSpec.describe Customer do
  describe 'relationships' do
    it {should have_many :invoices}
  end

  describe 'validations' do
    it {should validate_presence_of(:first_name)}
    it {should validate_presence_of(:last_name)}
  end

  describe "get all customers for merchant" do
    it "return all customers for merchant id" do
      merchant_1 = Merchant.create!(name: "Sam's")
      merchant_2 = Merchant.create!(name: "Target")

      customer_1 = Customer.create!(first_name: "Luke", last_name: "Skywalker")
      customer_2 = Customer.create!(first_name: "Harry", last_name: "Potter")
      customer_3 = Customer.create!(first_name: "Prince", last_name: "Adam")
      customer_4 = Customer.create!(first_name: "Princess", last_name: "She'Ra")

      invoice_1 = Invoice.create!(customer: customer_1, merchant: merchant_1, status: "shipped")
      invoice_2 = Invoice.create!(customer: customer_1, merchant: merchant_1, status: "shipped")
      invoice_3 = Invoice.create!(customer: customer_4, merchant: merchant_2, status: "shipped")
      invoice_4 = Invoice.create!(customer: customer_2, merchant: merchant_1, status: "shipped")
      invoice_5 = Invoice.create!(customer: customer_3, merchant: merchant_1, status: "shipped")

      merchant_id = Customer.filter_merchant_id(merchant_1.id)

      expect(merchant_id).to contain_exactly(customer_1, customer_2, customer_3)
    end
  end
  
end