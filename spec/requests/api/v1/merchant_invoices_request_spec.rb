require 'rails_helper'

RSpec.describe "Merchant Invoices" do
  describe "Index" do

    it "returns a list of all invoices for a single merchant" do
      walmart = Merchant.create!(name: "Walmart")
      
      customer = Customer.create!(first_name: "Michael", last_name: "Jackson")

      invoice_1 = Invoice.create!(customer: customer, merchant: walmart, status: "packaged")
      invoice_2 = Invoice.create!(customer: customer, merchant: walmart, status: "shipped")
      invoice_3 = Invoice.create!(customer: customer, merchant: walmart, status: "returned")

      get "/api/v1/merchants/#{walmart.id}/invoices"
      expect(response).to be_successful
      
      invoices = JSON.parse(response.body, symbolize_names: true)

      expect(invoices[:data].count).to eq(3)

      invoices[:data].each do |invoice|
        
        expect(invoice).to have_key(:id)
        expect(invoice[:id]).to be_a(String)

        expect(invoice).to have_key(:type)
        expect(invoice[:type]).to be_a(String)
        
        attributes = invoice[:attributes]
        
        expect(attributes).to have_key(:customer_id)
        expect(attributes[:customer_id]).to be_an(Integer)

        expect(attributes).to have_key(:merchant_id)
        expect(attributes[:merchant_id]).to be_an(Integer)

        expect(attributes).to have_key(:status)
        expect(attributes[:status]).to be_a(String)
      end
    end

    it "can return a merchants invoices filtered by status" do
      walmart = Merchant.create!(name: "Walmart")
      
      customer = Customer.create!(first_name: "Michael", last_name: "Jackson")

      invoice_1 = Invoice.create!(customer: customer, merchant: walmart, status: "packaged")
      invoice_2 = Invoice.create!(customer: customer, merchant: walmart, status: "shipped")
      invoice_3 = Invoice.create!(customer: customer, merchant: walmart, status: "returned")

      get "/api/v1/merchants/#{walmart.id}/invoices?status=shipped"
      expect(response).to be_successful

      invoices = JSON.parse(response.body, symbolize_names: true)
      expect(invoices[:data].count).to eq(1)
     
      invoices[:data].each do |invoice|
        
        expect(invoice).to have_key(:id)
        expect(invoice[:id]).to be_a(String)

        expect(invoice).to have_key(:type)
        expect(invoice[:type]).to be_a(String)
        
        attributes = invoice[:attributes]
        
        expect(attributes).to have_key(:customer_id)
        expect(attributes[:customer_id]).to be_an(Integer)

        expect(attributes).to have_key(:merchant_id)
        expect(attributes[:merchant_id]).to be_an(Integer)

        expect(attributes).to have_key(:status)
        expect(attributes[:status]).to be_a(String)
        expect(attributes[:status]).to eq("shipped")
      end
    end

    it "returns a 404 message if merchant is not found" do
      
      get "/api/v1/merchants/#{1234567890}/invoices"
      expect(response).to have_http_status(404)

      error_message = JSON.parse(response.body, symbolize_names: true)
      expect(error_message[:errors][0][:message]).to eq("Merchant not found")
    end
  end
end