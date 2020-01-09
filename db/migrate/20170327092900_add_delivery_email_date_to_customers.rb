class AddDeliveryEmailDateToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :delivery_email_sent_date, :datetime, after: :token
  end
end
