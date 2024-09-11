class InvoiceItemsSerializer
  include JSONAPI::Serializer
  attributes :quantity, :unit_price
end
