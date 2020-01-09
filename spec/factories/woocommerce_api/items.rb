FactoryBot.define do
  factory :woocommerce_item_params, class: ActiveSupport::HashWithIndifferentAccess do
    skip_create

    quantity { 1 }
    subtotal_tax { 10.12 }
    total_tax { 2.4 }
    subtotal { 3.2 }
    total { 20 }
    meta { [{ 'key' => 'Meta key', 'value' => 'Meta value', 'label' => 'Meta label' }] }

    initialize_with { new(attributes) }
  end
end
