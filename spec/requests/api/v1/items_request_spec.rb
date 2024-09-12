require 'rails_helper'

RSpec.describe "Items" do

  describe "create" do
    it "can create an item" do
      merchant = Merchant.create!(name: "Test Merchant")

      item_params = {
        item: {
          name: "Item English Book",
          description: "Book written in English and has black pages",
          unit_price: 49.99,
          merchant_id: merchant.id
        }
      }

      post api_v1_items_path, params: item_params, as: :json

      created_item = Item.last

      expect(response).to be_successful
      expect(response.code).to eq("200")
      expect(created_item.name).to eq("Item English Book") 
    end

    it "has a sad path for not being able to create an item" do
      merchant = Merchant.create!(name: "Test Merchant")

      invalid_item_params = {
        item: {
          name: "Item English Book",
          description: "Book written in English and has blank pages",
          merchant_id: merchant.id
        }
      }

      post api_v1_items_path, params: invalid_item_params, as: :json

      expect(response.status).to eq(422)

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors][0][:status]).to eq(422)
      expect(error_response[:errors][0][:message]).to eq("Unit price can't be blank")

      expect(error_response[:errors][1][:status]).to eq(422)
      expect(error_response[:errors][1][:message]).to eq("Unit price is not a number")
    end
  end
end