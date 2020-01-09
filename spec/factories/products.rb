FactoryBot.define do
  factory :product do
    title { "MyString" }
    type_product { "MyString" }
    status { "MyString" }
    permalink { "MyString" }
    sku { "MyString" }
    price { "" }
    regular_price { "" }
    sale_price { "" }
    total_sales { 1 }
  end
end
