class AddFirstOrderToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :first_order, :boolean, default: false, after: :note
    Order.reset_column_information
    
    Customer.find_each do |customer|
      customer.orders.order(created_at: :desc).last&.update_attribute(:first_order, true)
    end
  end
  
  def down
    remove_column :orders, :first_order
  end
end
