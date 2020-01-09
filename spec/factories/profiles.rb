FactoryBot.define do
  factory :profile do
    association :customer
    submitted { false }
    association :author, factory: :user
    association :submitter, factory: :user
  end
end
