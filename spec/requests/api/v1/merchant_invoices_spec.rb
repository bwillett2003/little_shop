require 'rails_helper'

RSpec.describe "Merchant Invoices" do
  describe "Index" do

    xit "returns a list of all invoices for a single merchant" do
      walmart = Merchant.create!(name: "Walmart")
      target = Merchant.create!(name: "Target")
      sams = Merchant.create!(name: "Sams")

      Invoice.create!

    end
  end
end