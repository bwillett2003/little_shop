require 'rails_helper'

RSpec.describe "Items Merchant" do
  describe "index" do

    it "returns the merchant associated with an item" do
      costco = Merchant.create!(name: "Costco")
      item = Item.create!(name: "Golden Egg", description: "A beautiful egg that is solid gold", unit_price: 29.99, merchant_id: costco.id)
    
      get "/api/v1/items/#{item.id}/merchant"
    
      expect(response).to be_successful
    
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]
    
      expect(merchant[:id]).to be_a(String)
      expect(merchant[:type]).to eq("merchant")
      expect(merchant[:attributes][:name]).to eq("Costco")
    end
    

    it "has a sad path for when item is not found" do
      costco = Merchant.create!(name: "Costco")
      item = Item.create!(name: "Golden Egg", description: "A beautiful egg that is solid gold", unit_price: 29.99, merchant_id: costco.id)

      get "/api/v1/items/#{item.id + 1}/merchant"

      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response).to have_key(:errors)
      expect(error_response[:errors].first).to have_key(:status)
      expect(error_response[:errors].first[:status]).to eq("404")

      expect(error_response[:errors].first).to have_key(:message)
      expect(error_response[:errors].first[:message]).to eq("Item not found")
    end
  end
end
