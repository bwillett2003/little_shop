require 'rails_helper'

RSpec.describe "Items" do

  describe "index" do
    it "gets can fetch all the items" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)
    
      get "/api/v1/items"
    
      expect(response).to be_successful
    
      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data].count).to eq(3)
    
      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an(String)

        expect(item).to have_key(:type)
        expect(item[:type]).to be_an(String)
    
        expect(item).to have_key(:attributes)
        attributes = item[:attributes]
    
        expect(attributes).to have_key(:name)
        expect(attributes[:name]).to be_a(String)
    
        expect(attributes).to have_key(:description)
        expect(attributes[:description]).to be_a(String)
    
        expect(attributes).to have_key(:unit_price)
        expect(attributes[:unit_price]).to be_a(Float)
    
        expect(attributes).to have_key(:merchant_id)
        expect(attributes[:merchant_id]).to be_an(Integer)
      end
    end
  end

  describe "show" do 
    it "gets data for one item" do
      merchant = Merchant.create!(name: "Lyra's Supplies")
      item_1 = Item.create!(name: "Golden Compass", description: "a truth-telling device", unit_price: 69.66, merchant_id: merchant.id)

      get "/api/v1/items/#{item_1.id}"

      expect(response).to be_successful

      item_response = JSON.parse(response.body, symbolize_names: true)

      expect(item_response).to have_key(:data)
      item = item_response[:data]

      expect(item).to have_key(:type)
      expect(item[:type]).to be_an(String)

      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

      expect(item).to have_key(:attributes)
      attributes = item[:attributes]

      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)

      expect(attributes).to have_key(:description)
      expect(attributes[:description]).to be_a(String)

      expect(attributes).to have_key(:unit_price)
      expect(attributes[:unit_price]).to be_a(Float)
    end

    it "sad path for not finding one item" do
      merchant = Merchant.create!(name: "Lyra's Supplies")
      item_1 = Item.create!(name: "Golden Compass", description: "a truth-telling device", unit_price: 69.66, merchant_id: merchant.id)

      get "/api/v1/items/#{item_1.id + 1}"

      expect(response).to have_http_status(:not_found)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors][0][:status]).to eq("404")
      expect(data[:errors][0][:message]).to eq("Record not found.")
    end
  end
end