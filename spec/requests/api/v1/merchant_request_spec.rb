require 'rails_helper'

RSpec.describe "Merchants" do
  describe "index" do
    it "gets a list of all merchants" do
      Merchant.create!(name: "Walmart")
      Merchant.create!(name: "Target")
      Merchant.create!(name: "Sam's")

      get "/api/v1/merchants"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants[:data].count).to eq(3)

      merchants[:data].each do |merchant|

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an(String)

        expect(merchant).to have_key(:attributes)
        attributes = merchant[:attributes]

        expect(attributes).to have_key(:name)
        expect(attributes[:name]).to be_a(String)
      end
    end
  end

  describe "show" do
    it "can get one merchant" do
      walmart = Merchant.create!(name: "Walmart")
      Merchant.create!(name: "Target")
      Merchant.create!(name: "Sam's")
      
      get "/api/v1/merchants/#{walmart.id}"
      
      expect(response).to be_successful
      
      merchant = JSON.parse(response.body, symbolize_names: true)
      
      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to eq(walmart.id.to_s)
      expect(merchant[:data][:attributes][:name]).to eq(walmart.name)
    end
    
    it "sad path for not finding one merchant" do
      Merchant.create!(name: "Target")
      Merchant.create!(name: "Sam's")
      walmart = Merchant.create!(name: "Walmart")
      
      get "/api/v1/merchants/#{walmart.id + 1}"
      
      expect(response).to have_http_status(:not_found)
      
      merchant = JSON.parse(response.body, symbolize_names: true)
      
      expect(merchant[:errors][0][:status]).to eq("404")
      expect(merchant[:errors][0][:message]).to eq("Record not found.")
    end
  end

  # describe "Update" do
  #   it "update an existing merchant" do
      
  #     merchant = Merchant.create!(name: "Walmart")
  #     previous_name = merchant.name
      
  #     merchant_params = {name: "Wally World"}
      
  #     headers = {"CONTENT_TYPE" => "application/json"}
      
  #     patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      
  #     updated_merchant = Merchant.find(merchant.id)

  #     expect(response).to be_successful
      
  #     expect(updated_merchant.name).to_not eq(previous_name)
  #     expect(updated_merchant.name).to eq("Wally World")
  #     end
  #   end
  # end

  describe "create" do
    it "can create a resource" do
      merchant_params = { name: "Costco"}

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant_params)

      expect(response).to be_successful

      created_merchant = Merchant.last
      expect(created_merchant[:name].to_s).to eq(merchant_params[:name])

      merchants_data = JSON.parse(response.body, symbolize_names: true)
      merchant = merchants_data[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(String)
      expect(merchant[:id]). to eq(created_merchant.id.to_s)
  
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to be_a(String)

      attributes = merchant[:attributes]

      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)
      expect(attributes[:name]).to eq(created_merchant.name)
    end

    it "can handle sad paths for requests with missing params" do
      bad_merchant_params = { store: "Costco"}

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants", headers: headers, params: JSON.generate(bad_merchant_params)

      
      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      errors_data = JSON.parse(response.body, symbolize_names: true)
      error = errors_data[:errors]

      expect(error[0][:message]).to eq("param is missing or the value is empty: merchant")
      expect(error[0][:status]).to eq(422)
    end

    it "can handle sad paths for requests with missing wrong params" do
      bad_merchant_params = {name: ""}

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants", headers: headers, params: JSON.generate(bad_merchant_params)


      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      errors_data = JSON.parse(response.body, symbolize_names: true)
      error = errors_data[:errors]
      
      expect(error[0][:message]).to eq("Name can't be blank")
      expect(error[0][:status]).to eq(422)
    end
  end

  describe "delete" do
    it "will delete a merchant and all items associated with the merchant" do
      merchant = Merchant.create!(name: "Walmart")
      item_1 = Item.create!(
        name: "Item Rerum Magni",
        description: "Iusto ratione illum. Adipisci est perspiciatis temporibus. Ducimus id dolorem voluptas eligendi repellat iure sit.",
        unit_price: 130.46,
        merchant_id: merchant.id
      )

      item_2 = Item.create!(
        name: "Item Et Cumque",
        description: "Ducimus id perferendis. Libero ullam odit aut quisquam non. Rem eaque distinctio quos. Eaque nihil odit.",
        unit_price: 130.46,
        merchant_id: merchant.id
      )

      expect(Merchant.count).to eq(1)
      expect(Item.count).to eq(2)

      delete "/api/v1/merchants/#{merchant.id}"

      expect(response).to be_successful

      expect(Merchant.count).to eq(0)
      expect{Merchant.find(merchant.id) }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Item.count).to eq(0)
      expect{Item.find(item_1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{Item.find(item_2.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  
    it "will can handle sad sad paths for merchants that don't exist" do
      merchant = Merchant.create!(name: "Walmart")

      delete "/api/v1/merchants/#{merchant.id + 1}"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      errors_data = JSON.parse(response.body, symbolize_names: true)
      error = errors_data[:errors]
      
      expect(error[0][:message]).to eq("Couldn't find Merchant with 'id'=#{merchant.id + 1}")
      expect(error[0][:status]).to eq(404)
    end

    it "sad path for not being able to update a merchant" do
    
      merchant = Merchant.create!(name: "Walmart")
      
      invalid_merchant = {name: ""}
      headers = {"CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate({merchant: invalid_merchant})
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      merchant = JSON.parse(response.body, symbolize_names: true)
      
      expect(merchant[:errors]).to include("Name can't be blank")
    end
  end
end