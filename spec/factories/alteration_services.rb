FactoryBot.define do
  factory :alteration_service do
    association :category
    name { 'Alteration service 1' }
    order { 0 }
  end
end
