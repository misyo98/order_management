FactoryBot.define do
  factory :profile_category_history do
    profile_category { nil }
    status { 'to_be_reviewed' }
    author { nil }
  end
end
