FactoryBot.define do
  factory :line_item_state_transition do
    line_item
    namespace { nil }
    event { 'wait' }
    from { 'new' }
    to { 'waiting_for_confirmation' }
    created_at { Date.today }
  end
end
