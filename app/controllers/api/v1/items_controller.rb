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


  def find
    if params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      return render json: {errors: {status: 400, message: "Can't filter on those params"}}, status: 400
    end

    if params[:name].present?
      item = Item.find_by_name(params[:name])
    end
    
    if (params[:min_price].present? && params[:min_price].to_f <= 0) || (params[:max_price].present? && params[:max_price].to_f <= 0)
      return render json: {errors: {status: 400, message: "Can't be less than 0 or a string."}}, status: 400
    end

    if (params[:min_price].present?) || (params[:max_price].present?)
      item = Item.all
                      .find_by_min_price(params[:min_price])
                      .find_by_max_price(params[:max_price])
                      .first
    end

    if item
      return render json: ItemsSerializer.new(item)
    end
    render json: {data: {}}
  end

  def update
    begin
      item = Item.find(params[:id])
      item.update!(item_params)
      render json: ItemsSerializer.new(item)
    rescue ActiveRecord::RecordNotFound => error
      error_message = [error.message]
      render json: error_messages(error_message, 404), status: 404
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 404), status: 404
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