class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.all
                      .sort_price(params[:sorted])
    render json: ItemsSerializer.new(items)
  end
  
  def show
    begin 
      item = Item.find(params[:id])
      render json: ItemsSerializer.new(item)
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
      item = Item.create!(item_params)
      render json: ItemsSerializer.new(item), status: 201
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: 422
    rescue ActionController::ParameterMissing => error
      error_message = [error.message]
      render json: error_messages(error_message, 422), status: 422
    end
  end

  def destroy
    begin
      item = Item.find(params[:id])
      item.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound => error
      error_message = [error.message]
      render json: error_messages(error_message, 404), status: 404
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
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