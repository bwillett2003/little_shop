require 'rails_helper'

RSpec.describe "Merchant Invoices" do
  describe "Index" do

    it "returns a list of all invoices for a single merchant" do
      walmart = Merchant.create!(name: "Walmart")
      
      customer = Customer.create!(first_name: "Michael", last_name: "Jackson")

      invoice_1 = Invoice.create!(customter: customer, merchant: walmart, status: "packaged")
      invoice_2 = Invoice.create!(customter: customer, merchant: walmart, status: "shipped")
      invoice_3 = Invoice.create!(customter: customer, merchant: walmart, status: "returned")

      get "/api/v1/merchants/#{walmart.id}/invoices"
      expect(response).to be_successful
      
      invoices = JSON.parse(response.body, symbolize_names: true)

      expect(invoices[:data].count).to eq(3)

      invoices[:data].each do |invoice|
        
        expect(invoice).to have_key(:id)
        expect(invoice[:id]).to be_a(String)

        expect(invoice).to have_key(:type)
        expect(invoice[:type]).to be_a(String)
        
        expect(invoice).to have_key(:attributes)
        expect(invoice[:attributes]).to be_a()
    end
  end
end