require 'rails_helper'

RSpec.describe "Customers" do
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
      
      get "/api/v1/merchants/#{merchant_1.id}/customers"

      customers = JSON.parse(response.body, symbolize_names: true)
      expect(customers[:data].count).to eq(3)

      full_names = customers[:data].map { |customer| "#{customer[:attributes][:first_name]} #{customer[:attributes][:last_name]}" }
      expect(full_names).to contain_exactly("Luke Skywalker", "Harry Potter", "Prince Adam")
    end
  end

  describe "has a sad path for when merchant is not found" do 
    it "test sad path" do

      get "/api/v1/merchants/#{1098989898}/customers"
    
      expect(response).to have_http_status(404)

      error_message = JSON.parse(response.body, symbolize_names: true)
      expect(error_message[:errors][0][:message]).to eq("Record not found.")
    end
  end

end