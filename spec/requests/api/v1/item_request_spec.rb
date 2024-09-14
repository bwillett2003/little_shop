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
      expect(response.code).to eq("201")
      expect(created_item.name).to eq("Item English Book") 
    end

    it "can handle sad paths for requests with missing params" do
      merchant = Merchant.create!(name: "Test Merchant")

      item_params = {
        item: {
          name: "Item English Book",
          description: "Book written in English and has black pages",
          merchant_id: merchant.id
        }
      }

      post api_v1_items_path, params: item_params, as: :json

      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      errors_data = JSON.parse(response.body, symbolize_names: true)
      error = errors_data[:errors]
      
      expect(error[0][:status]).to eq(422)
      expect(error[0][:message]).to eq("Unit price can't be blank")

      invalid_item_params = {}

      post api_v1_items_path, params: invalid_item_params, as: :json

      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      errors_data = JSON.parse(response.body, symbolize_names: true)
      error = errors_data[:errors]

      expect(error[0][:status]).to eq(422)
      expect(error[0][:message]).to eq("param is missing or the value is empty: item")
    end

    it "can handle sad paths for requests with incorrect params" do
      merchant = Merchant.create!(name: "Test Merchant")
    
      item_params = {
        item: {
          name: "",
          description: "Book written in English and has black pages",
          unit_price: 49.99,
          merchant_id: merchant.id
        }
      }
    
      post api_v1_items_path, params: item_params, as: :json
    
      expect(response).to_not be_successful
      expect(response.status).to eq(422)
    
      errors_data = JSON.parse(response.body, symbolize_names: true)
      error = errors_data[:errors]
    
      expect(error[0][:status]).to eq(422)
      expect(error[0][:message]).to eq("Name can't be blank")
    end    
  end

  describe "destroy" do
    it "can destroy an item" do
      merchant = Merchant.create!(name: "Test Merchant")

      item = Item.create!(
          name: "Item English Book",
          description: "Book written in English and has blank pages",
          unit_price: 49.99,
          merchant_id: merchant.id
      )

      expect(Item.count).to eq(1)

      delete "/api/v1/items/#{item.id}"

      expect(Item.count).to eq(0)
    end

    it "has a sad path for not being able to destroy an item" do
      merchant = Merchant.create!(name: "Test Merchant")

      non_existent_item_id = merchant.id + 1

      delete "/api/v1/items/#{non_existent_item_id}"

      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors][0][:status]).to eq(404)
      expect(error_response[:errors][0][:message]).to eq("Couldn't find Item with 'id'=#{non_existent_item_id}")
    end
  end
end