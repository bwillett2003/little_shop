class Api::V1::MerchantInvoicesController < ApplicationController

  def index
    merchant = Merchant.find(params[:id])
    invoices = Invoice.filter_merchant_status(merchant_params)
    render json: InvoicesSerializer.new(invoices)

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

  private

  def merchant_params
    {merchant_id: params[:id], status: params[:status]}
  end
end