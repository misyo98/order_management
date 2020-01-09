class AddIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :currency
  end
end
