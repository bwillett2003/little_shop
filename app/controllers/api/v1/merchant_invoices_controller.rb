class Api::V1::MerchantInvoicesController < ApplicationController

  def index
    invoices = Invoice.filter_merchant_status(params)
    render json: InvoicesSerializer.new(invoices)
  end

end