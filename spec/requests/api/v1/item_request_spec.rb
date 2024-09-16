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

  describe "update" do
    it "can update existing items" do
      merchant = Merchant.create!(name: "Walmart")
      id = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id).id
      previous_description = Item.last.description
      item_params = {description: "it's not a macbook"}

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      
      item = Item.find_by(id: id)
      expect(item.description).to_not eq(previous_description)
      expect(item.description).to eq("it's not a macbook")

      expect(response).to be_successful
      items_data = JSON.parse(response.body, symbolize_names: true)
      items = items_data[:data]


      expect(items).to have_key(:id)
      expect(items[:id]).to eq(id.to_s)

      expect(items).to have_key(:type)
      expect(items[:type]).to eq('item')

      expect(items).to have_key(:attributes)
      expect(items[:attributes]).to have_key(:name)
      expect(items[:attributes][:name]).to eq("Laptop")

      expect(items[:attributes]).to have_key(:description)
      expect(items[:attributes][:description]).to eq("it's not a macbook")

      expect(items[:attributes]).to have_key(:unit_price)
      expect(items[:attributes][:unit_price]).to eq(999.99)

      expect(items[:attributes]).to have_key(:merchant_id)
      expect(items[:attributes][:merchant_id]).to eq(merchant.id)
    end

    it "can handle sad path for nonexisten ids" do
      merchant = Merchant.create!(name: "Walmart")
      id = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id).id
      item_params = {description: "this won't update"}
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id+ 1}", headers: headers, params: JSON.generate({item: item_params})
  
      expect(response.status).to eq(404)
      
      error_data = JSON.parse(response.body, symbolize_names: true)
      expect(error_data).to have_key(:errors)

      expect(error_data[:errors].first).to have_key(:status)
      expect(error_data[:errors].first[:status]).to eq(404)

      expect(error_data[:errors].first).to have_key(:message)
      expect(error_data[:errors].first[:message]).to eq("Couldn't find Item with 'id'=#{id + 1}")
    end
  
    it "can handle sad path for invalid updates" do
      merchant = Merchant.create!(name: "Walmart")
      item = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)

      item_params = {name: "", description: "Invalid attempt"}
      headers = {"CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
  
      expect(response.status).to eq(404)
      error_data = JSON.parse(response.body, symbolize_names: true)

      expect(error_data).to have_key(:errors)

      error = error_data[:errors].first

      expect(error).to have_key(:status)
      expect(error[:status]).to eq(404)

      expect(error).to have_key(:message)
      expect(error[:message]).to eq("Name can't be blank")
  
    end

    it "updates item with valid merchant_id" do
      merchant1 = Merchant.create!(name: "Walmart")
      merchant2 = Merchant.create!(name: "Target")
      item = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant1.id)
  
      item_params = { merchant_id: merchant2.id }
  
      headers = { "CONTENT_TYPE" => "application/json" }
      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({ item: item_params })
  
      expect(response).to be_successful
  
      item.reload
      expect(item.merchant_id).to eq(merchant2.id)
  
      items_data = JSON.parse(response.body, symbolize_names: true)
      items = items_data[:data]
  
      expect(items[:attributes][:merchant_id]).to eq(merchant2.id)
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

  describe "find" do
    it "can find an item by its name" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      get "/api/v1/items?name=e"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)
      
      expect(items[:data][0][:attributes][:name]).to be_a(String)
      expect(items[:data][0][:attributes][:name]).to eq("Laptop")

      expect(items[:data][0][:attributes][:description]).to be_a(String)
      expect(items[:data][0][:attributes][:description]).to eq("A powerful laptop")

      expect(items[:data][0][:attributes][:unit_price]).to be_a(Float)
      expect(items[:data][0][:attributes][:unit_price]).to eq(999.99)

      expect(items[:data][0][:attributes][:merchant_id]).to be_a(Integer)
      expect(items[:data][0][:attributes][:merchant_id]).to eq(merchant.id)
    end

    it "has a sad path for not finding an item" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)
      
      get "/api/v1/items/find?name=qweporiu"

      expect(response).to be_successful

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:data]).to eq({})
    end

    it "can find an item by a min_price" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      get "/api/v1/items/find?min_price=999.99"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)
      
      expect(items[:data][:attributes][:name]).to be_a(String)
      expect(items[:data][:attributes][:name]).to eq("Laptop")

      expect(items[:data][:attributes][:description]).to be_a(String)
      expect(items[:data][:attributes][:description]).to eq("A powerful laptop")

      expect(items[:data][:attributes][:unit_price]).to be_a(Float)
      expect(items[:data][:attributes][:unit_price]).to eq(999.99)

      expect(items[:data][:attributes][:merchant_id]).to be_a(Integer)
      expect(items[:data][:attributes][:merchant_id]).to eq(merchant.id)
    end

    it "has a sad path for not finding an item by min_price" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)
      
      get "/api/v1/items/find?min_price=10000"

      expect(response).to be_successful

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:data]).to eq({})
    end

    it "can find an item by a max_price" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      get "/api/v1/items/find?max_price=199.99"

      expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)
      
      expect(item[:data][:attributes][:name]).to be_a(String)
      expect(item[:data][:attributes][:name]).to eq("Headphones")

      expect(item[:data][:attributes][:description]).to be_a(String)
      expect(item[:data][:attributes][:description]).to eq("Noise-canceling headphones")

      expect(item[:data][:attributes][:unit_price]).to be_a(Float)
      expect(item[:data][:attributes][:unit_price]).to eq(199.99)

      expect(item[:data][:attributes][:merchant_id]).to be_a(Integer)
      expect(item[:data][:attributes][:merchant_id]).to eq(merchant.id)
    end

    it "has a sad path for not finding an item by max_price" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)
      
      get "/api/v1/items/find?max_price=5"

      expect(response).to be_successful

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:data]).to eq({})
    end

    it "has a sad path for including both name and min_price params" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      get "/api/v1/items/find?name=Jose&min_price=10000"

      error_response = JSON.parse(response.body, symbolize_names: true)
      
      expect(error_response[:errors][:status]).to eq(400)
      expect(error_response[:errors][:message]).to eq("Can't filter on those params")
    end

    it "has a sad path for including both name and max_price params" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      get "/api/v1/items/find?name=Jose&max_price=10000"

      error_response = JSON.parse(response.body, symbolize_names: true)
      
      expect(error_response[:errors][:status]).to eq(400)
      expect(error_response[:errors][:message]).to eq("Can't filter on those params")
    end

    it "has a sad path for including name, min_price, and max_price params" do
      merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      get "/api/v1/items/find?name=Jose&min_price=500&max_price=10000"

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors][:status]).to eq(400)
      expect(error_response[:errors][:message]).to eq("Can't filter on those params")
    end

    it "has sad path for min_price query to be lower than 0 or string" do
    merchant = Merchant.create!(name: "Walmart")

      Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)
      
      get "/api/v1/items/find?min_price=Jose"

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors][:status]).to eq(400)
      expect(error_response[:errors][:message]).to eq("Can't be less than 0 or a string.")
    end
  end
end