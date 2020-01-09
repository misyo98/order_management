order = @items.first.order.decorate

json.total      order.formatted_total
json.subtotal   order.formatted_subtotal
json.currency   order.currency
json.total_tax  order.formatted_total_tax
json.discount   order.formatted_discount
json.order_items do
  json.array!(@items) do |item|
    item = OrderItemDecorator.new(item, context: { timelines: @timelines })

    json.id                       item.id
    json.product_id               item.product_id
    json.name                     item.name
    json.status                   item.status
    json.estimated_delivery_date  item.estimated_delivery_date
    json.tracking_link            item.tracking_link_field
    json.tracking_number          item.tracking_number_field
    json.total                    item.paid_price
    json.subtotal                 item.list_price
  end
end
