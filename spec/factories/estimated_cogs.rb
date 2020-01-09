FactoryBot.define do
  factory :estimated_cog do
    country { "MyString" }
    category { "MyString" }
    canvas { "MyString" }
    cmt { 1 }
    fabric_consumption { 1 }
    estimated_inbound_shipping_costs { 1 }
    estimated_duty { 1 }
  end
end
