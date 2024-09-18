class MerchantsSerializer
  include JSONAPI::Serializer
  attributes :name
  set_type :merchant

  attribute :item_count, if: Proc.new {|record, params| params[:item_count] == "true"} do |merchant|
    merchant.items.count
  end

end
