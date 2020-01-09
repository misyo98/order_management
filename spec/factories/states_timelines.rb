FactoryBot.define do
  factory :states_timeline do
    state { 'new' }
    from_event { 'payment_pending' }
    allowed_time_uk { 1 }
    allowed_time_sg { 2 }
    expected_delivery_time_sg { 1 }
    expected_delivery_time_uk { 2 }
    time_unit { 1 }
  end
end
