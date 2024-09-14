class Api::V1::MerchantInvoicesController < ApplicationController

  def index
    merchant = Merchant.find(params[:id])
    render json: InvoicesSerializer.new(merchant.invoices)

  end

end