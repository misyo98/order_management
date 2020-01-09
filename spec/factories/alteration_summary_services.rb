FactoryBot.define do
  factory :alteration_summary_service do
    association :alteration_summary
    association :alteration_service
  end
end
