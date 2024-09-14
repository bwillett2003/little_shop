class MerchantsSerializer
  include JSONAPI::Serializer
  attributes :name
  set_type :merchant

  attribute :item_count, if: proc { |merchants, params| params[:count] == 'true' } do |merchant|
    merchant.items.count
  end

end
