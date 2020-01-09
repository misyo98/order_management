FactoryBot.define do
  factory :fabric_option_value do
    fabric_option { nil }
    title { "MyString" }
    order { 1 }
    image_url { "MyText" }
    price { nil }
    premium { 1 }
    manufacturer { 1 }
  end
end
