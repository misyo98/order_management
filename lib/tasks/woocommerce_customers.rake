namespace :woocommerce_customers do
  desc "Checks for new customers and adds them to the db"
  task check_for_new: :environment do
    CheckForCustomers.perform_async
  end

  desc "Updates info on all customers"
  task update_all: :environment do
    UpdateCustomers.perform_async
  end

  task update_recent: :environment do
    UpdateRecentCustomers.perform_async
  end  
  
  task update_recent_manually: :environment do
    Woocommerce::Hub.update_recent_customers
  end

  task update_manually: :environment do
    Woocommerce::Hub.update_customers
  end

  task create_manually: :environment do
    Woocommerce::Hub.create_customers
  end

  task update_names: :environment do
    batch_size = 1000
    0.step(Customer.count, batch_size).each do |offset|
      Customer.all.offset(offset).limit(batch_size).each do |customer|
        next unless customer.first_name.blank?
        if customer.billing.first_name.present?
          customer.update_attribute(:first_name, customer.billing.first_name)
          customer.update_attribute(:last_name, customer.billing.last_name)
        elsif customer.shipping.first_name.present?
          customer.update_attribute(:first_name, customer.shipping.first_name)
          customer.update_attribute(:last_name, customer.shipping.last_name)
        elsif customer.orders.last && customer.orders.last.billing.first_name.present?
          customer.update_attribute(:first_name, customer.orders.last.billing.first_name)
          customer.update_attribute(:last_name, customer.orders.last.billing.last_name)
        end
      end
      puts "Done #{offset} customers!"
    end
  end

  task remove_bots: :environment do
    batch_size = 5
    0.step(Customer.where(Customer.arel_table[:email].matches("%@163.com")).count, batch_size).each do |offset|
      Customer.where(Customer.arel_table[:email].matches("%@163.com")).offset(offset).limit(batch_size).each do |customer|
        Billing.where(billable_id: customer.id, billable_type: 'Customer').delete_all
        Shipping.where(shippable_id: customer.id, shippable_type: 'Customer').delete_all
      end
      puts "Done #{offset} customers!"
    end
  end
end
