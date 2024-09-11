class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: MerchantsSerializer.new(merchants)
  end

  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantsSerializer.new(merchant)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end