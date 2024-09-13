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
end