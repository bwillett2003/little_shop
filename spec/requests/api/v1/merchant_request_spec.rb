require 'rails_helper'

RSpec.describe "Merchants" do
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

  it "returns a list of all items for a single merchant" do
    walmart = Merchant.create!(name: "Walmart")
    target = Merchant.create!(name: "Target")
    sams = Merchant.create!(name: "Sams")

    Item.create!(name: "Hat", description: "Bucket", unit_price: 1.99, merchant: walmart)
    Item.create!(name: "Shoes", description: "Pink and sparkly", unit_price: 5.00, merchant: walmart)
    Item.create!(name: "Bananas", description: "X-Large bunch", unit_price: 0.99, merchant: sams)

    get "/api/v1/merchants/#{target.id}/items"
    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)
    
    expect(items[:data].count).to eq(2)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes]).to have_key(:unit_price)
      end
  end



end