task update_state_from_last_event: :environment do
  items = LineItem.includes(:logged_events).all

  batch_size = 1000
  0.step(items.count, batch_size).each do |offset|    
    items.offset(offset).limit(batch_size).each do |item|
      next unless item.logged_events.any?

      last_state = item.logged_events.last.to
      item.update_attribute(:state, last_state)
    end
    puts "Done #{offset} Items!"
  end
end
