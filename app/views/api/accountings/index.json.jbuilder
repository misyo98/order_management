json.array!(@accountings) do |accounting|
  json.id                                       accounting.id
  json.status                                   accounting.status
  json.required_action                          accounting.required_action
  json.order_number                             accounting.order_number
  json.order_date                               accounting.order_date
  json.wc_status                                accounting.wc_status
  json.comment                                  accounting.comment_field
  json.first_name                               accounting.first_name
  json.last_name                                accounting.last_name
  json.billing_country                          accounting.billing_country
  json.shipping_country                         accounting.shipping_country
  json.email                                    accounting.email
  json.phone                                    accounting.phone
  json.customer                                 accounting.customer_id
  json.customer_type                            accounting.customer_type
  json.name                                     accounting.name
  json.quantity                                 accounting.quantity
  json.items_in_order                           accounting.items_in_order
  json.currency                                 accounting.currency
  json.item_subtotal                            accounting.item_subtotal
  json.item_total                               accounting.item_total
  json.discount                                 accounting.discount
  json.sales_person                             accounting.sales_person
  json.location_of_sale                         accounting.location_of_sale
  json.category                                 accounting.category
  json.canvas                                   accounting.canvas
  json.fabric_code                              accounting.fabric_code
  json.manufacturer_fabric_code                 accounting.manufacturer_fabric_code
  json.refunded_amount                          accounting.refunded_amount
  json.total_after_refund                       accounting.total_after_refund
  json.vat_rate                                 accounting.vat_rate
  json.total_net_vat                            accounting.total_net_vat
  json.cmt_cost_usd                             accounting.cmt_cost_usd
  json.fabric_consumption                       accounting.fabric_consumption
  json.fabric_cost                              accounting.fabric_cost
  json.manufacturing_costs                      accounting.manufacturing_costs
  json.estimated_inbound_shipping_costs         accounting.estimated_inbound_shipping_costs
  json.estimated_duty                           accounting.estimated_duty
  json.estimated_cogs                           accounting.estimated_cogs
  json.real_manufacturing_costs                 accounting.real_manufacturing_costs
  json.real_cogs_fabric_addition_per_meter      accounting.real_cogs_fabric_addition_per_meter
  json.real_cogs_fabric_addition_total          accounting.real_cogs_fabric_addition_total
  json.real_cogs_fabric_cmt_and_fabric_addition accounting.real_cogs_fabric_cmt_and_fabric_addition
  json.real_inbound_shipping_costs              accounting.real_inbound_shipping_costs
  json.real_duty_usd                            accounting.real_duty_usd
  json.real_cogs_landed_usd                     accounting.real_cogs_landed_usd
  json.fx_usd_local_currency                    accounting.fx_usd_local_currency
  json.real_cogs_landed_local_currency          accounting.real_cogs_landed_local_currency
  json.margin                                   accounting.margin
  json.remake                                   accounting.is_remake
  json.created_at                               accounting.created_at
end
