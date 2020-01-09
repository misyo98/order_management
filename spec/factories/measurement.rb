FactoryBot.define do
  factory :measurement do
    association :profile, factory: :profile
    category_param { nil }
    category_param_value { nil }
    sequence(:value) { Random.new().rand(1..30) }
    sequence(:allowance) { Random.new().rand(7) }
    adjustment { nil }
    final_garment { Random.new().rand(1..30) }
    trait :height do
      sequence(:value) { Random.new().rand(50..80)}
      sequence(:final_garment) { Random.new().rand(50..80) }
    end
  end
end
