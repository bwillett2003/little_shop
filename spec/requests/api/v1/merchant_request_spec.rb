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

  describe "create" do
    it "can create a resource" do
      merchant_params = { name: "Costco"}



      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant_params)

      expect(response).to be_successful

      created_merchant = Merchant.last
      expect(created_merchant).to eq(merchant_params[:name])

      merchants_data = JSON.parse(response.body, symbolize_names: true)
      merchant = merchants_data[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(String)
      expect(merchant[:id]). to eq(created_merchant.id)
  
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to be_a(String)

      attributes = merchant[:attributes]

      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)
      expect(attributes[:name]).to eq(created_merchant.name)
    end
  end
end