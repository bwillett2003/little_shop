class Api::V1::ItemsController < ApplicationController

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