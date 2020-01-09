FactoryBot.define do
  factory :line_item do
    subtotal { 1000 }
    subtotal_tax { 0 }
    total { 1000 }
    total_tax { 0 }
    price { 1000 }
    quantity { 1 }
    tax_class { 'Tax' }
    name { 'Shirt' }
    sku { 'SKU' }
    outbound_tracking_number { 7778111 }
    sequence(:m_order_number) { |n| "PES#{n}" }
    sales_location
    state_entered_date { nil }
    association :sales_person, factory: :user
    association :order
    association :product
    association :courier, factory: :courier_company
    vat_export { false }
  end
end
