class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: MerchantsSerializer.new(merchants)
  end

  def show
    begin
      merchant = Merchant.find(params[:id])
      render json: MerchantsSerializer.new(merchant)
    rescue ActiveRecord::RecordNotFound
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

  def update
    begin
      merchant = Merchant.find(params[:id])
      if merchant.update(merchant_params)
        render json: MerchantsSerializer.new(merchant)
      else
        render json: {errors: merchant.errors.full_messages}, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
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
  

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end