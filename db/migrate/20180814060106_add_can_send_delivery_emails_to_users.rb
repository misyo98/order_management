class AddCanSendDeliveryEmailsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :can_send_delivery_emails, :boolean, default: true
  end
  
  def down
    remove_column :users, :can_send_delivery_emails
  end
end
