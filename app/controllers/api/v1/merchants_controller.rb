class Api::V1::MerchantsController < ApplicationController
  
  def index
    merchants = Merchant.all
                            .sort_direction(params[:sorted])
                            .filter_returned(params[:status])
                      
    render json: MerchantsSerializer.new(merchants, {params: {item_count: params[:count] }})
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


  def create
    begin
      merchant = Merchant.create!(merchant_params)
      render json: MerchantsSerializer.new(merchant), status: 200
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: 422
    rescue ActionController::ParameterMissing => error
      error_message = [error.message]
      render json: error_messages(error_message, 422), status: 422
    end
  end

  def destroy
    begin 
      merchant = Merchant.find(params[:id])
      merchant.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound => error
      error_message = [error.message]
      render json: error_messages(error_message, 404), status: 404
    end
  end

  def update
    begin
      merchant = Merchant.find(params[:id])
      merchant.update!(merchant_params)
      render json: MerchantsSerializer.new(merchant), status: 202
    rescue ActiveRecord::RecordNotFound => error
      error_message = [error.message]
      render json: error_messages(error_message, 404), status: 404
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: 422
    end
  end

  def find_all
    merchant = Merchant.all
                    .find_by_merchant_name(params[:name])
    if merchant
      return render json: MerchantsSerializer.new(merchant)
    end
    render json: {data: []}
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end

  def error_messages(messages, status)
    {
      errors: messages.map do |message|
        {
          status: status,
          message: message
        }
      end
    }
  end
  
end