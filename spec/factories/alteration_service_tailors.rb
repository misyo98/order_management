FactoryBot.define do
  factory :alteration_service_tailor do
    association :alteration_service
    association :alteration_tailor
    price { 15 }
  end
end
