FactoryBot.define do
  factory :payment_detail do
    order_id { 1 }
    method_id { "MyString" }
    method_title { "MyString" }
    paid { "MyString" }
    transaction_id { "MyString" }
  end
end
