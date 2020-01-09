class AddIndexToPaymentDetails < ActiveRecord::Migration
  def change
    add_index :payment_details, :order_id
  end
end
