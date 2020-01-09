task setup_item_statuses: :environment do
  batch_size = 1000
  0.step(Order.count, batch_size).each do |offset|
    Order.all.offset(offset).limit(batch_size).each do |order|
      state = order.processing? || order.completed? ? 'new' : 'payment_pending'
      order.line_items.update_all(state: state)
    end
    puts "Done #{offset} Orders!"
  end
end