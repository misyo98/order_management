FactoryBot.define do
  factory :shipping do
    customer_id { 1 }
    first_name { "MyString" }
    last_name { "MyString" }
    company { "MyString" }
    address_1 { "MyString" }
    address_2 { "MyString" }
    city { "MyString" }
    state { "MyString" }
    postcode { "MyString" }
    country { "MyString" }
  end
end
