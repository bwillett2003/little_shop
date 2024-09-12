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
  end
end