class Api::V1::ItemsMerchantController < ApplicationController

  def index
    item = Item.find(params[:id])
    render json: MerchantsSerializer.new(item.merchant)

  rescue ActiveRecord::RecordNotFound
    render json: {
      errors: [
        {
          status: "404",
          message: "Item not found"
        }
      ]
    }, status: :not_found
  end
end