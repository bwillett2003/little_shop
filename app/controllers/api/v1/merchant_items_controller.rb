class Api::V1::MerchantItemsController < ApplicationController
  
  def index
    merchant = Merchant.find(params[:id])
    render json: ItemsSerializer.new(merchant.items)

  rescue ActiveRecord::RecordNotFound
    render json: {
      errors: [
        {
          status: "404",
          message: "Merchant not found"
        }
      ]
    }, status: :not_found
  end
end