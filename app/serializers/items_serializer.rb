class ItemsSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price, :merchant_id
  set_type :item
end
