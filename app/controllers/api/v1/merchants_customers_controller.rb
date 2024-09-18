class Api::V1::MerchantsCustomersController < ApplicationController

  def index
    begin
      merchant = Merchant.find(params[:merchant_id])
      customers = Customer.filter_merchant_id(merchant.id)
      render json: CustomerSerializer.new(customers)
    rescue ActiveRecord::RecordNotFound => errors
      render json: {
        errors: [
          {
            status: "404", 
            message: "Record not found."
          }
        ]
      }, status: 404
    end
  end

end
