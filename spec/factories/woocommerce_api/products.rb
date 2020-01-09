FactoryBot.define do
  factory :woocommerce_product, class: ActiveSupport::HashWithIndifferentAccess do
    skip_create

    id             { 1 }
    title          { 'New Product' }
    type           { 'simple' }
    status         { 'publish' }
    permalink      { 'exmaplehost.dot.com' }
    sku            { 'ES_1' }
    price          { 119.0 }
    regular_price  { 119.0 }
    sale_price     { nil }
    total_sales    { 666 }
    categories     { ['MADE-TO-MEASURE JACKETS', 'bla', 'hello'] }
    created_at     { Date.yesterday }
    updated_at     { Date.today }

    initialize_with { new(attributes) }
  end
end
