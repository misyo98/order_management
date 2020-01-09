FactoryBot.define do
  factory :allowance do
    category_param_id { 1 }
    slim { "9.99" }
    singapore_slim { "9.99" }
    regular { "9.99" }
    classic { "9.99" }
  end
end
