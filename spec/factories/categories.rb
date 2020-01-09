FactoryBot.define do
  factory :category do
    sequence(:name) { |i| "Category-#{i}" }
    visible { nil }
    order { nil }
    sequence(:parameterized_name) { |i| "category_#{i}" }
  end
end
