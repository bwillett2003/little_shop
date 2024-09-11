class TransactionsSerializer
  include JSONAPI::Serializer
  attributes :credit_card_number, :credit_card_expiration_date, :result
end
