class ItemsSerializer
  include JSONAPI::Serializer

  set_type :item
  attributes :name, :description, :unit_price, :merchant_id
end
