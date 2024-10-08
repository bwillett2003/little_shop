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

  describe "index sort by age" do
    it "lists newest merchants first descending order" do
      Merchant.create!(name: "Sam's")
      Merchant.create!(name: "Target")
      Merchant.create!(name: "Walmart")
      
      get "/api/v1/merchants?sorted=age"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)
  
      expect(merchants[:data].count).to eq(3)
 
      expect(merchants[:data].first[:attributes][:name]).to eq("Walmart")
      expect(merchants[:data].last[:attributes][:name]).to eq("Sam's")
    end
  end

  describe "index item count" do
    it "returns merchants with item_count when count is true" do
      merchant_1 = Merchant.create!(name: "Walmart")
      merchant_2 = Merchant.create!(name: "Target")
  
      merchant_1.items.create!(name: "Golden Compass", description: "a truth-telling device", unit_price: 690.66)
      merchant_2.items.create!(name: "Lightsaber", description: "glows purple and chops people in half", unit_price: 515.45)
      merchant_2.items.create!(name: "Buc-ee's Tumbler", description: "holds hot or cold liquid / 16oz", unit_price: 8.95)
  
      get "/api/v1/merchants?count=true"
      
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data][0][:attributes][:item_count]).to eq(1)
      expect(merchants[:data][1][:attributes][:item_count]).to eq(2)
    end

    it "does not include item_count when count is not true" do
      merchant_1 = Merchant.create!(name: "Walmart")
      merchant_2 = Merchant.create!(name: "Target")
      
      merchant_1.items.create!(name: "Golden Compass", description: "a truth-telling device", unit_price: 690.66)
      
      get "/api/v1/merchants"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)
      
      expect(merchants[:data][0][:attributes]).not_to have_key(:item_count)
    
      get "/api/v1/merchants?count=false"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)
      
      expect(merchants[:data][0][:attributes]).not_to have_key(:item_count)
    end
  end

  describe "index returned" do
    it "returns merchants with items from an invoice returned" do
      merchant_invoice_returned = Merchant.create!(name: "Walmart")
      merchant_invoice_not_returned = Merchant.create!(name: "Target")

      customer_1 = Customer.create!(first_name: "Luke", last_name: "Skywalker")
      customer_2 = Customer.create!(first_name: "Harry", last_name: "Potter")

      Invoice.create!(merchant: merchant_invoice_returned, status: "returned", customer: customer_1)
      Invoice.create!(merchant: merchant_invoice_not_returned, status: "paid", customer: customer_2)

      get "/api/v1/merchants?status=returned"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)
      merchant_names = merchants[:data].map {|merchant| merchant[:attributes][:name]}

      expect(merchant_names).to eq([merchant_invoice_returned.name])
      expect(merchant_names).not_to include(merchant_invoice_not_returned.name)   
    end

    it "returns empty when no merchants have returned invoices" do
      merchant = Merchant.create!(name: "Walmart")
      customer_1 = Customer.create!(first_name: "Luke", last_name: "Skywalker")

      Invoice.create!(merchant: merchant, status: "paid", customer: customer_1)

      get "/api/v1/merchants?status=returned"
    
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data]).to be_empty
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
  
  describe "Update" do
    it "can update existing merchants" do
      merchant = Merchant.create!(name: "Walmart")
      previous_name = merchant.name
      merchant_params = {merchant:{name: "Target"}}
    
      headers = { "CONTENT_TYPE" => "application/json" }
      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate(merchant_params)

      updated_merchant = Merchant.find_by(id: merchant.id)

      expect(updated_merchant.name).to_not eq(previous_name)
      expect(updated_merchant.name).to eq("Target")
    
      expect(response).to be_successful
      merchant_data = JSON.parse(response.body, symbolize_names: true)
      merchant_json = merchant_data[:data]
    
      expect(merchant_json).to have_key(:id)
      expect(merchant_json[:id]).to eq(merchant.id.to_s)
    
      expect(merchant_json).to have_key(:type)
      expect(merchant_json[:type]).to eq('merchant')
    
      expect(merchant_json).to have_key(:attributes)
      expect(merchant_json[:attributes]).to have_key(:name)
      expect(merchant_json[:attributes][:name]).to eq("Target")
    end

    it "can handle sad paths when the merchant does not exist" do
      merchant = Merchant.create!(name: "Walmart")
      non_existent_id = merchant.id + 1
      merchant_params = { name: "Target" }
    
      headers = { "CONTENT_TYPE" => "application/json" }
      patch "/api/v1/merchants/#{non_existent_id}", headers: headers, params: JSON.generate({ merchant: merchant_params })
    
      expect(response.status).to eq(404)
    
      error_data = JSON.parse(response.body, symbolize_names: true)
      expect(error_data).to have_key(:errors)
    
      error = error_data[:errors].first
    
      expect(error).to have_key(:status)
      expect(error[:status]).to eq(404)
    
      expect(error).to have_key(:message)
      expect(error[:message]).to eq("Couldn't find Merchant with 'id'=#{non_existent_id}")
    end

    it "can handle sad paths when the update is invalid" do
      merchant = Merchant.create!(name: "Walmart")
      
      merchant_params = { name: "" }
      headers = { "CONTENT_TYPE" => "application/json" }
    
      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate({ merchant: merchant_params })
    
      expect(response.status).to eq(422)
    
      error_data = JSON.parse(response.body, symbolize_names: true)
      expect(error_data).to have_key(:errors)
    
      error = error_data[:errors].first
    
      expect(error).to have_key(:status)
      expect(error[:status]).to eq(422)
    
      expect(error).to have_key(:message)
      expect(error[:message]).to eq("Name can't be blank")
    end
  end

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
  
    it "will can handle sad paths for merchants that don't exist" do
      merchant = Merchant.create!(name: "Walmart")
      previous_name = merchant.name
      
      invalid_merchant = {name: ""}
      headers = {"CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate({merchant: invalid_merchant})
      
      expect(response.status).to eq(422)
      
      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:errors].first[:status]).to eq(422)
      expect(merchant[:errors].first[:message]).to eq("Name can't be blank")
    end
  end

  describe "find_all" do
    it "can find all merchants with search criteria" do
      Merchant.create!(name: "Walmart")
      Merchant.create!(name: "Target")
      Merchant.create!(name: "Sam's")

      get "/api/v1/merchants/find_all?name=w"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data][0]).to have_key(:id)
      expect(merchants[:data][0][:id]).to be_an(String)

      expect(merchants[:data][0]).to have_key(:type)
      expect(merchants[:data][0][:type]).to be_an(String)

      attributes = merchants[:attributes]

      expect(merchants[:data][0][:attributes][:name]).to be_a(String)
      expect(merchants[:data][0][:attributes][:name]).to eq("Walmart")
    end

    it "has a sad path for not being able to find a merchant with search criteria" do
      Merchant.create!(name: "Walmart")
      Merchant.create!(name: "Target")
      Merchant.create!(name: "Sam's")

      get "/api/v1/merchants/find_all?name=qweproiu"

      expect(response).to be_successful

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:data]).to eq([])
    end
  end
end