task update_last_order: :environment do
  batch_size = 1000
  0.step(Customer.count, batch_size).each do |offset|
    Customer.all.includes(:orders).offset(offset).limit(batch_size).each do |customer|
      next unless customer.orders.any?
      last_order_id = customer.orders.last.id
      customer.update_column(:last_order_id, last_order_id)
    end
    puts "Done #{offset} customers!"
  end
end