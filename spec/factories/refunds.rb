FactoryBot.define do
  factory :refund do
    line_item { nil }
    amount { "9.99" }
    currency { "MyString" }
    reason { "MyString" }
  end
end
