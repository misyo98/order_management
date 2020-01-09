class AddDeliveryEmailLayoutToEmailsQueues < ActiveRecord::Migration
  def change
    add_column :emails_queues, :delivery_email_layout, :integer, default: 0
  end
end
