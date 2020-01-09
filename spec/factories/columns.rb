FactoryBot.define do
  factory :column do
    columnable_type { 'LineItem' }
    columnable_id { nil }
    name { 'status' }
    order { 1 }
    visible { false }
    label { 'Status' }
    sorting_scope { 'status' }
  end
end
