FactoryBot.define do
  factory :profile_category do
    association :profile
    association :category
    status { :to_be_submitted }
  end
end
