FactoryBot.define do
  factory :param do
    sequence(:title) { |i| "Param-#{i}" }
    input_type { 0 }
    sequence(:parameterized_name) { |i| "param_#{i}" }
  end
end
