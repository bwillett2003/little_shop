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
      updated_merchant = Merchant.find(params[:id])
      render json: MerchantSerializer.new(updated_merchant)
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