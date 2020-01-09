FactoryBot.define do
  factory :line_item_scope do
    label { "Scope1" }
    states { ['new', 'payment_pending'] }
    show_counter { true }
    visible_for { ['admin', 'ops', 'outfitter'] }
  end
end
