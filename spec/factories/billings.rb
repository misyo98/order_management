FactoryBot.define do
  factory :billing do
    customer_id { nil }
    first_name { 'MyString' }
    last_name { 'MyString' }
    email { 'MyString' }
    company { 'MyString' }
    address_1 { 'MyString' }
    address_2 { 'MyString' }
    city { 'MyString' }
    state { 'MyString' }
    postcode { 'MyString' }
    country { 'MyString' }
    phone { 'MyString' }

    trait :order do
      billable_id { nil }
      billable_type { 'Order' }
    end

    factory :billing_order, traits: [:order]
  end
end
