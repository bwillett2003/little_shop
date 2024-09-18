require 'rails_helper'

RSpec.describe Item do
  describe 'relationships' do
    it {should belong_to :merchant}
    it {should have_many :invoice_items}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
    it {should validate_presence_of(:description)}
    it {should validate_presence_of(:unit_price)}
    it {should validate_numericality_of(:unit_price)}
    it {should validate_presence_of(:merchant_id)}
    it {should validate_numericality_of(:merchant_id)}

  end

  describe "sort_price" do
    it "can return all items storted by price" do
      merchant = Merchant.create!(name: "Walmart")

      item1 = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      item2 = Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      item3 = Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      items = Item.sort_price("price")
      
      expect(items.first).to eq(item3) 
      expect(items.second).to eq(item2)
      expect(items.third).to eq(item1)
    end
  end

  describe "find_by_name" do
    it "can Find an item based on search criteria" do
      merchant = Merchant.create!(name: "Walmart")

      item1 = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      item2 = Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      item3 = Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      found_item = Item.find_by_name("Laptop")

      expect(found_item).to eq(item1)
      expect(found_item).to_not eq(item2)
    end
  end

  describe "find_by_min_price" do
    it "can Find an item based on search criteria" do
      merchant = Merchant.create!(name: "Walmart")

      item1 = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      item2 = Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      item3 = Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      found_item = Item.find_by_min_price(499.99)

      expect(found_item).to include(item1, item2)
      expect(found_item).to_not include(item3)
    end
  end

  describe "find_by_max_price" do
    it "can Find an item based on search criteria" do
      merchant = Merchant.create!(name: "Walmart")

      item1 = Item.create!(name: "Laptop", description: "A powerful laptop", unit_price: 999.99, merchant_id: merchant.id)
      item2 = Item.create!(name: "Phone", description: "A sleek smartphone", unit_price: 499.99, merchant_id: merchant.id)
      item3 = Item.create!(name: "Headphones", description: "Noise-canceling headphones", unit_price: 199.99, merchant_id: merchant.id)

      found_item = Item.find_by_max_price(499.99)

      expect(found_item).to include(item2, item3)
      expect(found_item).to_not include(item1)
    end
  end
end