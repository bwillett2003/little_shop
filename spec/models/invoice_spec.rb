require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationships' do
    it {should belong_to :customer}
    it {should belong_to :merchant}
    it {should have_many :invoice_items}
    it {should have_many :transactions}
  end

  describe 'validations' do
    it {should validate_presence_of(:customer_id)}
    it {should validate_numericality_of(:customer_id)}
    it {should validate_presence_of(:merchant_id)}
    it {should validate_numericality_of(:merchant_id)}
    it {should validate_presence_of(:status)}
  end

  describe "merchant invoices filter" do
    it "returns a merchants invoices filtered by status" do
      walmart = Merchant.create!(name: "Walmart")
      
      customer = Customer.create!(first_name: "Michael", last_name: "Jackson")

      invoice_1 = Invoice.create!(customer: customer, merchant: walmart, status: "packaged")
      invoice_2 = Invoice.create!(customer: customer, merchant: walmart, status: "shipped")
      invoice_3 = Invoice.create!(customer: customer, merchant: walmart, status: "returned")

      filtered_invoices = Invoice.filter_merchant_status({merchant_id: walmart.id, status: "shipped"})

      expect(filtered_invoices.count).to eq(1)
      expect(filtered_invoices.first.status).to eq("shipped")
    end
  end
end