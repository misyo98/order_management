FactoryBot.define do
  factory :measurement_check_height_cluster do
    measurement_check { nil }
    upper_limit { 55 }
    min { 0.30 }
    max { 0.40 }
  end
end
