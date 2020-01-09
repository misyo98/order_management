namespace :update_all_addresses do
  task billings: :environment do
    Billing.all.each do |billing|
      billing.update(billable_id: billing.customer_id, billable_type: 'Customer')
    end
    puts 'Success!'
  end

  task shippings: :environment do
    Shipping.all.each do |shipping|
      shipping.update(shippable_id: shipping.customer_id, shippable_type: 'Customer')
    end
    puts 'Success!'
  end
end