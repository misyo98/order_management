json.customer do
  if @customer
    json.first_name         @customer.billing_first_name
    json.last_name          @customer.billing_last_name
    json.email              @customer.email
    json.phone              @customer.billing_phone
    json.last_order_id      @customer.last_order_id
    json.postal_code        @customer.billing_postcode
    json.supplied_address   @customer.billing_address_1
    json.address_2          @customer.billing_address_2
  else
    json.null!
  end
end
