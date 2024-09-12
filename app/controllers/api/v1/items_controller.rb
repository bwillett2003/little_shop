class Api::V1::ItemsController < ApplicationController
  def create
    begin
      item = Item.create(item_params)
      render json: ItemsSerializer.new(item)
    rescue ActionController::ParameterMissing
      render json: {
        errors: [
          {
            status: "404",
            message: "Unable to complete task. Please try again."
          }
        ]
      }, status: 404
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end