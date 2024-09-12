class Api::V1::ItemsController < ApplicationController

  def show
    item = Item.find(params[:id])
    render json: ItemsSerializer.new(item)
  end
end