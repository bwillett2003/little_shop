require 'rails_helper'

RSpec.describe "Merchant Items" do
  describe "Index" do

    it "returns a list of all items for a single merchant" do
      walmart = Merchant.create!(name: "Walmart")
      target = Merchant.create!(name: "Target")
      sams = Merchant.create!(name: "Sams")

      Item.create!(name: "Hat", description: "Bucket", unit_price: 1.99, merchant: walmart)
      Item.create!(name: "Shoes", description: "Pink and sparkly", unit_price: 5.00, merchant: walmart)
      Item.create!(name: "Bananas", description: "X-Large bunch", unit_price: 0.99, merchant: sams)

      get "/api/v1/merchants/#{walmart.id}/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)
      
        expect(items[:data].count).to eq(2)

        items[:data].each do |item|

          expect(item).to have_key(:id)
          expect(item[:id]).to be_a(String)

          expect(item[:attributes]).to have_key(:name)
          expect(item[:attributes][:name]).to be_a(String)

          expect(item[:attributes]).to have_key(:description)
          expect(item[:attributes][:description]).to be_a(String)

          expect(item[:attributes]).to have_key(:unit_price)
          expect(item[:attributes][:unit_price]).to be_a(Float)
        end
    end

    it "returns a 404 message if merchant is not found" do
      
      get "/api/v1/merchants/#{1234567890}/items"
      expect(response).to have_http_status(404)

      error_message = JSON.parse(response.body, symbolize_names: true)
      expect(error_message[:errors][0][:message]).to eq("Merchant not found")
    end
  end
end