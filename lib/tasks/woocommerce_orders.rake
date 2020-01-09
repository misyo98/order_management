namespace :woocommerce_orders do
  task check_for_new: :environment do
    CheckForOrders.perform_async
  end 
  task update_statuses: :environment do
    UpdateOrdersStatuses.perform_async
  end

  task create: :environment do
    Woocommerce::Hub.create_orders
  end

  task update: :environment do
    Woocommerce::Hub.update_orders_statuses
  end

  task :create_single, [:order_id] => :environment do |task, args|
    Woocommerce::Hub.create_single_order(args[:order_id])
  end

  task remove_all_with_dependencies: :environment do
    PaymentDetail.all.delete_all
    Billing.where(billable_type: 'Order').delete_all
    Shipping.where(shippable_type: 'Order').delete_all
    LineItem.all.delete_all
    Order.all.delete_all
    puts 'Success!'
  end

  task separate_line_items: :environment do
    batch_size = 1000
    0.step(LineItem.multiple_item.count, batch_size).each do |offset|
      persisted_items = LineItem.multiple_item.offset(offset).limit(batch_size)
      new_items = []
      persisted_items.each do |line_item|
        (line_item.quantity  - 1).times do |index|
          new_items << LineItem.new(line_item.attributes.merge!(quantity: 1, id: nil))
        end
      end
      persisted_items.update_all(quantity: 1)
      LineItem.import new_items
      puts "Done #{offset} items! Count of new items = #{new_items.count}"
    end
  end

  task update_acquisition_channel: :environment do
    woocommerce = Woocommerce::OrderApi.new()

    1.upto woocommerce.last_page do |index|
      params = woocommerce.orders(page: index)
      params.each do |order_params|
        print '.'
        acquisition_channel = order_params.dig('order_meta', 'Acquisition channel')

        next if acquisition_channel.blank?

        order = Order.find_by(id: order_params['id'])

        next unless order

        order.line_items.update_all(acquisition_channel: acquisition_channel)
        print '!'
      end
      puts "== Updated #{params.count} orders; Page: #{index} =="
    end
  end
end
