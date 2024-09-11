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
end