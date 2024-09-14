class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items
  has_many :transactions

  validates :customer_id, presence: true, numericality: {only_integer: true}
  validates :merchant_id, presence: true, numericality: {only_interger: true}
  validates :status, presence: true

  def self.filter_merchant_status(params)
    invoices = Invoice.where(merchant_id: params[:id])
    invoices = filter(invoices, params)
    invoices
  end

  def self.filter(invoices, params)
    if params[:status].present?
      invoices = invoices.where(status: params[:status])
    end
    
    invoices
  end
end