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
    
    it "has a sad path for not finding one merchant" do
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

  describe "Update action" do
    it "update an existing merchant" do
      
      merchant = Merchant.create!(name: "Walmart")
      previous_name = merchant.name
      
      merchant_params = {name: "Wally World"}
      
      headers = {"CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      
      updated_merchant = Merchant.find(merchant.id)

      expect(response).to be_successful
      
      expect(updated_merchant.name).to_not eq(previous_name)
      expect(updated_merchant.name).to eq("Wally World")
    end
  end
end