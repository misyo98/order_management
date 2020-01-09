FactoryBot.define do
  factory :sales_location_timeline do
    sales_location
    states_timeline
    allowed_time { 1 }
    expected_delivery_time { 1 }
  end
end
